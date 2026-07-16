variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region for SDSC workload resource group"
  type        = string
}

variable "resource_group_name" {
  description = "Dedicated resource group for SDSC deployment"
  type        = string
}

variable "cluster_name" {
  description = "SDSC cluster name"
  type        = string
}

variable "is_multi_az" {
  description = "Single-AZ=false, Multi-AZ=true"
  type        = bool
  default     = false
}

variable "zones" {
  description = "Single-AZ example [\"1\"], Multi-AZ example [\"1\",\"2\",\"3\"]"
  type        = list(string)
}

variable "time_zone" {
  description = "Linux/IANA timezone"
  type        = string
  default     = "Asia/Kolkata"
}

variable "cluster_structure" {
  description = "Mirroring Duplication or HPEC 4D+2P"
  type        = string
}

variable "storage_account_name" {
  description = "Storage account for logs/output"
  type        = string
}

variable "virtual_network_resource_group_name" {
  description = "RG where shared VNet exists"
  type        = string
}

variable "virtual_network_name" {
  description = "Existing VNet name"
  type        = string
}

variable "control_subnet_name" {
  description = "Existing control subnet name"
  type        = string
}

variable "internode_subnet_name" {
  description = "Existing internode subnet name"
  type        = string
}

variable "compute_subnet_name" {
  description = "Existing compute subnet name"
  type        = string
}

variable "compute_ipv6_enable" {
  description = "Enable IPv6 on compute network"
  type        = bool
  default     = false
}

variable "compute_port_protocol" {
  description = "iSCSI or NVMe/TCP"
  type        = string
}

variable "control_mtu_size" {
  type    = number
  default = 1500
}

variable "internode_mtu_size" {
  type    = number
  default = 1500
}

variable "compute_mtu_size" {
  type    = number
  default = 1500
}

variable "control_network_allowed_ipv4_add_cidr_blocks" {
  type    = list(string)
  default = []
}

variable "compute_network_allowed_ipv4_add_cidr_blocks" {
  type    = list(string)
  default = []
}

variable "compute_network_allowed_ipv6_add_cidr_blocks" {
  type    = list(string)
  default = []
}

variable "storage_node_vm_size" {
  type = string
}

variable "number_of_nodes" {
  type = number
}

variable "number_of_drives" {
  type = number
}

variable "drive_size" {
  type = number
}

variable "drive_iops" {
  type    = number
  default = 3000
}

variable "drive_throughput" {
  type    = number
  default = 125
}

variable "disk_encryption_set_id" {
  type    = string
  default = ""
}

variable "billing_code" {
  type    = string
  default = ""
}


variable "compute_ipv6_address_array" {
  type    = list(string)
  default = []
}




variable "storage_pool_name" {
  type    = string
  default = "StoragePool01"
}


variable "deletion_protection" {
  description = "Must remain false for destroy-safe Terraform lifecycle"
  type        = bool
  default     = false

  validation {
    condition     = var.deletion_protection == false
    error_message = "Set deletion_protection = false. Your uploaded ARM template can create CanNotDelete locks when true."
  }
}


variable "vm_custom_data" {
  type    = string
  default = "IyEvYmluL3NoCm5vZGUtaW5pdAo="
}

variable "installation_setting_method" {
  type    = string
  default = "Standard"
}


variable "version_vm_image" {
  description = "Usually keep vendor defaults unless you need a specific image"
  type = list(object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  }))
  default = [
    {
      publisher = "hitachivantara"
      offer     = "vsp_one_sds_block_image"
      sku       = "01_18_04_50_byol"
      version   = "latest"
    }
  ]
}

variable "node_vm_images" {
  type    = list(number)
  default = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
}