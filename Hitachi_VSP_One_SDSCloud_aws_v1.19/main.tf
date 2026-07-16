resource "aws_cloudformation_stack" "vsp_one_sds_block_test" {
  name          = "test-PI-19-3-tf-trial"
  template_body = file("${path.module}/templates/vsp-sds-block-template.yaml")
  capabilities  = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]

  parameters = {
    ClusterName                  = var.cluster_name
    AvailabilityZone             = var.availability_zone
    VpcId                        = var.vpc_id
    ControlSubnetId              = var.control_subnet_id
    ControlNetworkCidrBlock      = var.control_network_cidr
    InterNodeSubnetId            = var.internode_subnet_id
    ComputeSubnetId              = var.compute_subnet_id
    ComputeIpVersion             = var.compute_ip_version
    ComputePortProtocol          = var.compute_port_protocol
    StorageNodeInstanceType      = var.storage_node_instance_type
    ConfigurationPattern         = var.configuration_pattern
    DriveCount                   = var.drive_count
    PhysicalDriveCapacity        = var.physical_drive_capacity
    EbsVolumeEncryption          = var.ebs_volume_encryption
    EbsVolumeKmsKeyId            = var.ebs_volume_kms_key_id
    TimeZone                     = var.time_zone
    BillingCode                  = var.billing_code
    S3URI                        = var.s3_uri
    IamRoleCreationMode          = var.iam_role_creation_mode
    IamRoleNameForStorageCluster = var.iam_role_name_for_storage_cluster
    ImageId                      = var.image_id
    MPS3BucketName               = var.mps3_bucket_name
    MPS3BucketRegion             = var.mps3_bucket_region
    MPS3KeyPrefix                = var.mps3_key_prefix
  }

  timeouts {
    create = "60m"
    update = "60m"
  }
}