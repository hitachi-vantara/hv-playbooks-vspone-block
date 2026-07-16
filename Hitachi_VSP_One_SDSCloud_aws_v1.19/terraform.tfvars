cluster_name                      = "VSPOneSDSBlock--04"
availability_zone                 = "us-west-2a"

vpc_id                            = "vpc-XXX"
control_subnet_id                 = "subnet-XXX"
control_network_cidr              = "10.7.X.X/XX"
internode_subnet_id               = "subnet-XXX"
compute_subnet_id                 = "subnet-XXX"

compute_ip_version                = "ipv4"
compute_port_protocol             = "iSCSI"
storage_node_instance_type        = "r6i.8xlarge"
configuration_pattern             = "Mirroring Duplication ( 3 Nodes )"
drive_count                       = "6"
physical_drive_capacity           = "Mirroring Duplication 1579 GiB"
ebs_volume_encryption             = "disable"
ebs_volume_kms_key_id             = "None"
time_zone                         = "UTC"
billing_code                      = "VSPOneSDSBlock"
s3_uri                            = "s3://XXXX/1.19/"
iam_role_creation_mode            = "Manual"
iam_role_name_for_storage_cluster = "SDSXXX"

## Do not chnage the below parameters 

image_id            = "/aws/service/marketplace/prod-4o3qqwmrr6yqe/version-1.19.01.30-0011"
mps3_bucket_name    = "awsmp-cft-053155443450-1579814207723"
mps3_bucket_region  = "us-east-1"
mps3_key_prefix     = "1116124c-bf19-4b4c-a208-f88e9b31df3b/d5ee2dc6-a777-40a4-b15d-ae4a4671f843/d0731770-73b0-48ec-a032-c90df04da543/"
