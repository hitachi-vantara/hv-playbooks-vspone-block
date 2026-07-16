variable "region" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "availability_zone" {
  type = string
}

variable "ControlNetworkCidrBlock" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "control_subnet_id" {
  type = string
}

variable "internode_subnet_id" {
  type = string
}

variable "compute_subnet_id" {
  type = string
}

variable "storage_node_instance_type" {
  type = string
}

variable "configuration_pattern" {
  type = string
}

variable "drive_count" {
  type = string
}

variable "physical_drive_capacity" {
  type = string
}

variable "ebs_volume_encryption" {
  type = string
}

variable "ebs_volume_kms_key_id" {
  type = string
}

variable "time_zone" {
  type = string
}

variable "billing_code" {
  type = string
}

variable "s3_uri" {
  type = string
}

variable "iam_role_name" {
  type = string
}

variable "jmp_host_ip" {
  type        = string
  description = "Enter your Jumphost IP/Subnet (e.g., 203.0.113.10/32) to access SDSC from your Jumphost"
}

variable "rosa_subnet_cidr" {
  type        = string
  description = "ROSA Worker Node subnet CIDR that needs access to SDS API and iSCSI"
}

variable "sds_admin_username" {
  description = "Admin username for SDS Block"
  type        = string
}

variable "sds_new_password" {
  description = "Admin password (after password reset) for SDS Block"
  type        = string
  sensitive   = true
}
variable "sds_default_password" {
  description = "Default SDS admin password before reset"
  type        = string
  sensitive   = true
}

#ROSA Variables 
#
# Input variables for ROSA HCP Single-AZ Private Cluster
#

variable "token" {
  type        = string
  description = "RHCS API token obtained from https://cloud.redhat.com"
  default     = ""
}

variable "aws_region" {
  type        = string
  default     = ""
  description = "AWS region to deploy the ROSA cluster"
}

variable "rosacluster_name" {
  type        = string
  default     = ""
  description = "Name of the ROSA HCP cluster"
}

variable "openshift_version" {
  type        = string
  default     = ""
  description = "OpenShift version for the ROSA HCP cluster"
}

variable "account_role_prefix" {
  type        = string
  default     = ""
}

variable "operator_role_prefix" {
  type        = string
  default     = ""
}

variable "aws_subnet_ids" {
  type        = list(string)
  default     = [""]
  description = "List of existing private subnet IDs for the ROSA cluster"
}

variable "private" {
  type        = bool
  default     = true
  description = "Deploy a private-only cluster"
}

variable "admin_password" {
  type        = string
  default     = ""
  description = "Password for cluster-admin user"
}

variable "pod_cidr" {
  type        = string
  default     = ""
}

variable "service_cidr" {
  type        = string
  default     = ""
}

variable "machine_cidr" {
  type        = string
  default     = ""
}

variable "compute_nodes" {
  type        = number
  default     = 
  description = "Number of worker nodes"
}

variable "compute_machine_type" {
  type        = string
  default     = ""
  description = "Instance type for compute nodes"
}

variable "oidc_endpoint_url" {
  type        = string
  default     = ""
  description = "Existing OIDC provider endpoint URL"
}

variable "oidc_config_id" {
  type        = string
  default     = ""
  description = "Existing OIDC configuration ID"
}

variable "default_aws_tags" {
  type        = map(string)
  default     = {
    Environment = "dev"
    Terraform   = "true"
  }
}

variable "jump_server_cidr" {
  type        = string
  description = "CIDR block of the existing jump server network that should access the ROSA API and console."
  default     = ""
}


