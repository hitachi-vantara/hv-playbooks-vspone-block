# Automated IaC: VSP One SDS Cloud on AWS + ROSA + PostgreSQL (Persistent Storage)

This repository provides an end-to-end **Terraform + Ansible** automation to deploy:

- **AWS infrastructure** (VPC/subnets/IAM/EC2 as required)
- **Hitachi VSP One SDS Cloud (SDSC)** cluster on AWS
- **ROSA (Red Hat OpenShift Service on AWS)** cluster
- **Hitachi Storage Plug-in for Containers (HSPC) / CSI** integration (iSCSI)
- **PostgreSQL** sample workload using **dynamic PVC → PV** provisioning
---
For detailed architecture, design considerations, and validated deployment guidance, refer to the official Hitachi Vantara Reference Architecture:
https://docs.hitachivantara.com/v/u/en-us/application-optimized-solutions/mk-sl-416 

---

## High-level Workflow

1. Provision **VSP One SDS Cloud** nodes on AWS
2. Initialize SDSC cluster
3. Run **Python password reset** for SDS admin credentials
4. Run **Ansible** to add attached disks into SDSC **storage pool**
5. Provision **ROSA** cluster
6. Install **HSPC/CSI + iSCSI daemonsets**
7. Create **Secret + StorageClass**
8. Create **PVC → PV** (SDS volume + LUN)
9. Deploy **PostgreSQL** pod using the SDS-backed PV

---

## Repository Structure

```text
.
├── ansible
│   ├── get_cluster_serial.yml
│   ├── get_sds_cluster_facts.yml
│   ├── storage_pool.yml
│   └── storage_var.yml
├── k8s_manifests
│   ├── hspc-operator-namespace.yaml
│   ├── hspc-operator.yaml
│   ├── hspc-sa-rbac.yaml
│   ├── hspc_v1_hspc.yaml
│   ├── iscsi.yaml
│   ├── postgresql-deploy.yaml
│   ├── pvc.yaml
│   ├── secret.tpl
│   └── storageclass.yaml
├── output.tf
├── password_reset.py
├── providers.tf
├── rosa.tf
├── sds.tf
├── terraform.tfvars
└── variable.tf
---

Prerequisites:

    Accounts / Access
        AWS account with permissions to create networking/IAM/EC2/related resources

        Red Hat account with ROSA enabled and a valid ROSA offline token

        Access to install HSPC/CSI components into the target ROSA cluster

Tooling (recommended versions)
On the Terraform/Ansible Dev VM (Amazon Linux 2023 recommended):

    Terraform (example: 1.13.x)

    Ansible (core 2.15+)

    Python 3.x

    AWS CLI v2

    ROSA CLI

    oc CLI

    Hitachi SDS Block Cloud 1.17

The reference guide includes an example Dev VM baseline and tooling list.

Configuration
    Update terraform.tfvars with your environment values:

        AWS region / AZ

        VPC + subnet IDs (control / internode / compute / ROSA worker)

        Instance types for SDSC nodes

        ROSA cluster variables (name, versions, CIDRs, node counts, roles, etc.)

        Jump host CIDR/IP allowlists

        SDS admin credential inputs (default + new password)

Important: Some workflows require careful handling of ROSA OIDC depending on whether Terraform creates it or you provide an existing one.

ROSA OIDC Options
    Option A (Terraform creates OIDC): Set create_oidc = true (if supported by your module/implementation)

    Option B (Use existing OIDC): Set create_oidc = false and provide:

        oidc_endpoint_url

        oidc_config_id



1) Initialize Terraform
    terraform init

2) Review plan
    terraform plan

3) Apply
    terraform apply
    # type: yes
    Terraform will orchestrate the full workflow (SDSC deploy + password reset + pool expansion + ROSA + CSI + manifests + PostgreSQL), depending on how sds.tf / rosa.tf are wired in your environment.

Post-deployment Validation
    Check PVC / PV
    oc get pvc
    oc get pv
    Check PostgreSQL pod
    oc get pods
    oc describe pod <postgres-pod-name>
    Verify mount inside pod
    oc exec -it <postgres-pod-name> -- /bin/bash
    df -h
    If the PVC/POD is initially Pending, wait a few minutes; the SDSC backend may still be completing capacity allocation.

Cleanup / Destroy
    ⚠️ This will delete the deployed resources managed by Terraform:

    terraform destroy

Troubleshooting Tips
ROSA login issues:

    Re-authenticate: rosa login then verify rosa whoami

PVC stuck Pending:

    Check CSI pods: oc get pods -n <hspc-namespace>

    Check iSCSI daemonset status:

    Check StorageClass and Secret existence

iSCSI connectivity:

    Ensure worker subnet CIDR can reach SDS iSCSI target on TCP/3260

    Confirm security groups / NACL rules

SDS admin password mismatch:

    Confirm password_reset.py ran successfully and terraform.tfvars matches the actual password used by CSI secret

Security Notice:

    This repository is intended for lab, PoC, and reference deployments.

Before using in production environments:

    Integrate with your organization’s secrets management solution

    Follow corporate security and change-management policies

    Review IAM roles and network access rules

Disclaimer

    This automation is provided as a reference implementation based on the Hitachi Vantara validated architecture.

    It is the responsibility of the user to validate, secure, and adapt the deployment for production workloads.