
# AWS Environment Details 
region                = "us-west-2"
cluster_name          = "VSPOneSDSBlock-PI-8"
availability_zone     = "us-west-2a"
ControlNetworkCidrBlock = "X.X.X.X/X"

# AWS VPC and Subnet Details 

vpc_id                = "vpc-xxxxx"
control_subnet_id     = "subnet-01-xxxx"
internode_subnet_id   = "subnet-02-xxxx"
compute_subnet_id     = "subnet-03-xxxx"

# Hitachi VSP One SDS Block Configuration Details 

storage_node_instance_type = "m6i.8xlarge"
configuration_pattern  = "Mirroring Duplication ( 3 Nodes )"
drive_count            = "6"
physical_drive_capacity = "Mirroring Duplication 1579 GiB"

ebs_volume_encryption  = "disable"
ebs_volume_kms_key_id  = "None"


time_zone              = "UTC"
billing_code           = "xxxx"
s3_uri                 = "s3://<bucket_name>/CF_Log/"
iam_role_name          = "xxxx"


#Provide your Jumphost IP/Subnet (replace example below),uncomment and modify if you want to hardcode the value
#Otherwise pass it during "terraform apply".


jmp_host_ip            = "X.X.X.X/X"

#Allow ROSA workers iSCSI access to SDS storage (TCP 3260)
rosa_subnet_cidr = "XX.XX.XX.XX/X"

#SDS Credentials 
sds_admin_username = "admin"
sds_new_password   = "NTest@123"
sds_default_password = "hsds-admin"



## ROSA Variables 

token              = "xxxxx"
aws_region         = "us-west-2" # Replace with your AWS region
rosacluster_name       = "pi-my-rosa-cluster"
openshift_version  = "4.19.13" # Verify with `rosa list versions`
account_role_prefix = "pi-my-rosa-account"
operator_role_prefix = "pi-my-rosa-hcp"
aws_subnet_ids     = ["subnet-04-xxxx"] # Replace with your private subnet IDs
private            = true
admin_password     = "Testrosa@123456789" # Replace with a secure password
pod_cidr           = "10.128.0.0/14"
service_cidr       = "172.30.0.0/16"
machine_cidr       = "X.X.X.X/X"

compute_nodes       = 2
compute_machine_type       = "m5.xlarge"
oidc_endpoint_url = "oidc.op1.openshiftapps.com/xxxxxxx"
oidc_config_id    = "xxxxxxxx"
jump_server_cidr = "X.X.X.X/X"


