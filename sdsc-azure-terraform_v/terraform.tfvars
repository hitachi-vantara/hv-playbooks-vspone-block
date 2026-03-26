subscription_id = "7c12ee7a-f79a-4d01-a897-edf7474cdcd9"

location            = "xxxxx"
resource_group_name = "xxxx"

cluster_name      = "VSPOneSDSBlock-pi-01"
is_multi_az       = false
zones             = ["1"]
time_zone         = "UTC"
cluster_structure = "Mirroring Duplication"

storage_account_name = "vxxxxxx"
billing_code         = "VSPOneSDSBlock"

virtual_network_resource_group_name = "xxx"
virtual_network_name                = "xxx"
control_subnet_name                 = "Ixxx"
internode_subnet_name               = "xxxx"
compute_subnet_name                 = "xxxx"

compute_ipv6_enable   = false
compute_port_protocol = "iSCSI"

control_mtu_size   = 1500
internode_mtu_size = 3900
compute_mtu_size   = 3900

control_network_allowed_ipv4_add_cidr_blocks = []
compute_network_allowed_ipv4_add_cidr_blocks = []
compute_network_allowed_ipv6_add_cidr_blocks = []

storage_node_vm_size = "Standard_E32s_v5"
number_of_nodes      = 3
number_of_drives     = 6

drive_size       = 1024
drive_iops       = 3000
drive_throughput = 125

disk_encryption_set_id = ""
deletion_protection = false
installation_setting_method = "Standard"

version_vm_image = [
  {
    publisher = "hitachivantara"
    offer     = "vsp_one_sds_block_image"
    sku       = "01_18_04_50_byol"
    version   = "latest"
  }
]

node_vm_images = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
