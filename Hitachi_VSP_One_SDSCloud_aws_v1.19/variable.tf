variable "cluster_name" {
  type        = string
  description = "Name of the VSP One SDS Block cluster"
}

variable "availability_zone" {
  type        = string
  description = "Availability zone for the storage cluster"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the storage cluster"
}

variable "control_subnet_id" {
  type        = string
  description = "Subnet ID for the control network"
}

variable "control_network_cidr" {
  type        = string
  description = "CIDR block for the control network"
}

variable "internode_subnet_id" {
  type        = string
  description = "Subnet ID for the internode network"
}

variable "compute_subnet_id" {
  type        = string
  description = "Subnet ID for the compute network"
}

variable "compute_ip_version" {
  type        = string
  description = "IP version for the compute network (ipv4 or ipv4v6)"
}

variable "compute_port_protocol" {
  type        = string
  description = "Network protocol for compute network port (iSCSI or NVMe/TCP)"
}

variable "storage_node_instance_type" {
  type        = string
  description = "EC2 instance type for each storage node"
}

variable "configuration_pattern" {
  type        = string
  description = "Data protection method and number of storage nodes"
}

variable "drive_count" {
  type        = string
  description = "Number of drives per storage node"
}

variable "physical_drive_capacity" {
  type        = string
  description = "Physical capacity of drive matching the configuration pattern"
}

variable "ebs_volume_encryption" {
  type        = string
  description = "Enable or disable individual EBS encryption (disable or enable)"
}

variable "ebs_volume_kms_key_id" {
  type        = string
  description = "KMS Key ID if ebs_volume_encryption is enable"
}

variable "time_zone" {
  type        = string
  description = "Time zone of the VSP One SDS Block cluster"
}

variable "billing_code" {
  type        = string
  description = "Cost monitoring code for the cluster"
}

variable "s3_uri" {
  type        = string
  description = "S3 folder for error message output during installation"
}

variable "iam_role_creation_mode" {
  type        = string
  description = "Mode for creating the IAM role (Auto or Manual)"
}

variable "iam_role_name_for_storage_cluster" {
  type        = string
  description = "IAM role name for the storage cluster (only if mode is Manual)"
}

variable "image_id" {
  type        = string
  description = "SSM parameter alias for the Marketplace AMI"
}

variable "mps3_bucket_name" {
  type        = string
  description = "S3 bucket containing the nested Marketplace templates"
}

variable "mps3_bucket_region" {
  type        = string
  description = "Region of the Marketplace nested-template S3 bucket"
}

variable "mps3_key_prefix" {
  type        = string
  description = "Key prefix of the nested templates in the Marketplace S3 bucket"
}