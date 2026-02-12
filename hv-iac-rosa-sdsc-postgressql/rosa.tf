
######################################################################
# SDS → ROSA LOCAL VARIABLES (FIXED)
######################################################################
locals {
  sds_endpoint_b64 = base64encode("https://${data.aws_lb.lb.dns_name}")
  sds_user_b64     = base64encode(var.sds_admin_username)
  sds_pass_b64     = base64encode(var.sds_new_password)


  # Render secret using built-in templatefile() function
  sds_secret_rendered = templatefile(
    "${path.module}/k8s_manifests/secret.tpl",
    {
      storage_url  = local.sds_endpoint_b64
      storage_user = local.sds_user_b64
      storage_pass = local.sds_pass_b64
    }
  )
}

resource "local_file" "secret_yaml" {
  content  = local.sds_secret_rendered
  filename = "${path.module}/k8s_manifests/secret.yaml"
}


######################################################################
# DATA SOURCES
######################################################################
data "aws_subnet" "selected" {
  id = var.aws_subnet_ids[0]
}

data "aws_vpc" "selected" {
  id = data.aws_subnet.selected.vpc_id
}

data "aws_availability_zones" "available" {}

locals {
  region_azs = slice([for zone in data.aws_availability_zones.available.names : zone], 0, 1)
}

######################################################################
# STEP 1 – ROSA CLUSTER CREATION
######################################################################
module "rosa_hcp" {
  source                 = "terraform-redhat/rosa-hcp/rhcs"
  version                = "1.6.9"

  cluster_name           = var.rosacluster_name
  openshift_version      = var.openshift_version
  account_role_prefix    = var.account_role_prefix
  operator_role_prefix   = var.operator_role_prefix
  replicas               = var.compute_nodes
  aws_availability_zones = local.region_azs
  compute_machine_type   = var.compute_machine_type

  private        = var.private
  aws_subnet_ids = var.aws_subnet_ids
  machine_cidr   = var.machine_cidr
  service_cidr   = var.service_cidr
  pod_cidr       = var.pod_cidr

  create_oidc       = false
  oidc_endpoint_url = var.oidc_endpoint_url
  oidc_config_id    = var.oidc_config_id

  create_account_roles  = true
  create_operator_roles = true

  create_admin_user          = true
  admin_credentials_username = "cluster-admin"
  admin_credentials_password = var.admin_password
}

######################################################################
# STEP 2 – SECURITY GROUPS (JUMP SERVER ACCESS)
######################################################################
resource "aws_security_group" "rosa_access_sg" {
  name        = "${var.rosacluster_name}-rosa-access-sg"
  description = "Allow Jump Server CIDR to access ROSA API and console"
  vpc_id      = data.aws_vpc.selected.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_jump_to_rosa_api" {
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  security_group_id = aws_security_group.rosa_access_sg.id
  cidr_blocks       = [var.jump_server_cidr]
}

resource "aws_security_group_rule" "allow_jump_to_rosa_console" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.rosa_access_sg.id
  cidr_blocks       = [var.jump_server_cidr]
}

######################################################################
# STEP 3 – GET KUBECONFIG
######################################################################
resource "null_resource" "get_kubeconfig" {
  depends_on = [module.rosa_hcp]

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOT
set -euo pipefail

echo "DEBUG: rosacluster_name from Terraform = ${var.rosacluster_name}"
PASSWORD="${var.admin_password}"

API_URL=$(rosa describe cluster -c "${var.rosacluster_name}" -o json | jq -r '.api.url')

echo "Waiting for ROSA API..."

for i in {1..25}; do
  if oc login "$API_URL" \
    --username=cluster-admin \
    --password="$PASSWORD" \
    --insecure-skip-tls-verify=true >/dev/null 2>&1; then
    break
  fi
  sleep 10
done

oc config view --raw --minify > kubeconfig
EOT
  }
}

######################################################################
# STEP 3.4 – INSTALL iSCSI INIT
######################################################################
resource "null_resource" "install_iscsi_init" {
  depends_on = [null_resource.get_kubeconfig]

  provisioner "local-exec" {
    command = <<EOT
set -euo pipefail
K=./kubeconfig

#oc --kubeconfig="$K" apply -f k8s_manifests/rosa-daemonset.yaml

oc --kubeconfig="$K" apply -f k8s_manifests/hspc-sa-rbac.yaml
sleep 5  
oc --kubeconfig="$K" apply -f k8s_manifests/iscsi.yaml
sleep 30
oc --kubeconfig="$K" get pods -n kube-system -l name=hspc-iscsi-init
EOT
  }
}

######################################################################
# STEP 4 – DEPLOY HSPC OPERATOR + CR
######################################################################
resource "null_resource" "deploy_hspc_operator" {
  depends_on = [
    null_resource.get_kubeconfig,
    null_resource.install_iscsi_init
  ]

  provisioner "local-exec" {
    command = <<EOT
set -euo pipefail
K=./kubeconfig

oc --kubeconfig="$K" apply -f k8s_manifests/hspc-operator-namespace.yaml
oc --kubeconfig="$K" apply -f k8s_manifests/hspc-operator.yaml
oc --kubeconfig="$K" apply -f k8s_manifests/hspc_v1_hspc.yaml
EOT
  }
}

######################################################################
# STEP 5 – DEPLOY SECRET + SC + PVC
######################################################################
resource "null_resource" "apply_secret" {
  depends_on = [
    local_file.secret_yaml,
    null_resource.get_kubeconfig
  ]
  provisioner "local-exec" {
    command = <<EOT
set -euo pipefail
K=./kubeconfig
oc --kubeconfig="$K" apply -f k8s_manifests/secret.yaml
EOT
  }
}

resource "null_resource" "deploy_storage" {
  depends_on = [
    null_resource.deploy_hspc_operator,
    null_resource.apply_secret
  ]

  provisioner "local-exec" {
    command = <<EOT
set -euo pipefail
K=./kubeconfig
for f in storageclass.yaml pvc.yaml; do
  oc --kubeconfig="$K" apply -f k8s_manifests/$f
done
EOT
  }
}

######################################################################
# STEP 6 – DEPLOY POSTGRES
######################################################################
resource "null_resource" "deploy_postgresql" {
  depends_on = [null_resource.deploy_storage]

  provisioner "local-exec" {
    command = <<EOT
set -euo pipefail
K=./kubeconfig
oc --kubeconfig="$K" apply -f k8s_manifests/postgresql-deploy.yaml
EOT
  }
}
