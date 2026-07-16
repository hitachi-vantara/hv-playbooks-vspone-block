locals {
  tags = {
    managedBy = "terraform"
    workload  = "sdsc"
  }

  parameters_json = templatefile("${path.module}/templates/parameters.tftpl.json", {
    cluster_name                                    = var.cluster_name
    location                                        = var.location
    is_multi_az                                     = var.is_multi_az
    zones                                           = var.zones
    time_zone                                       = var.time_zone
    cluster_structure                               = var.cluster_structure
    storage_account_name                            = var.storage_account_name
    virtual_network_resource_group_name             = var.virtual_network_resource_group_name
    virtual_network_name                            = var.virtual_network_name
    control_subnet_name                             = var.control_subnet_name
    internode_subnet_name                           = var.internode_subnet_name
    compute_subnet_name                             = var.compute_subnet_name
    compute_ipv6_enable                             = var.compute_ipv6_enable
    compute_port_protocol                           = var.compute_port_protocol
    control_mtu_size                                = var.control_mtu_size
    internode_mtu_size                              = var.internode_mtu_size
    compute_mtu_size                                = var.compute_mtu_size
    control_network_allowed_ipv4_add_cidr_blocks    = var.control_network_allowed_ipv4_add_cidr_blocks
    compute_network_allowed_ipv4_add_cidr_blocks    = var.compute_network_allowed_ipv4_add_cidr_blocks
    compute_network_allowed_ipv6_add_cidr_blocks    = var.compute_network_allowed_ipv6_add_cidr_blocks
    storage_node_vm_size                            = var.storage_node_vm_size
    number_of_nodes                                 = var.number_of_nodes
    number_of_drives                                = var.number_of_drives
    drive_size                                      = var.drive_size
    drive_iops                                      = var.drive_iops
    drive_throughput                                = var.drive_throughput
    disk_encryption_set_id                          = var.disk_encryption_set_id
    billing_code                                    = var.billing_code
    

    
    storage_pool_name                               = var.storage_pool_name
    
    version_vm_image                                = var.version_vm_image
    node_vm_images                                  = var.node_vm_images
    deletion_protection                             = var.deletion_protection
    
    
    vm_custom_data                                  = var.vm_custom_data
    installation_setting_method                     = var.installation_setting_method
    
  })
}