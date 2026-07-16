# Playbooks for End-to-End Hitachi Universal Volume Manager Configuration.

These Ansible playbooks were customized to align with the environment’s specific requirements. These modified playbooks were then executed to automate the configuration of Hitachi UVM, ensuring consistent, efficient, and error-free deployment of UVM across the connected storage systems.

## Playbook: (pool_create_from_PG_ext_storage.yml) [Create DP pool from existing Parity Group in external storage]
This Ansible playbook is designed to Create DP pool from existing Parity Group in VSP external storage.

## Playbook: (multiple_LDEV_create_from_Pool_ext_storage.yml)[Create LDEVs from DP Pool in external storage]
This playbook performs to create LDEV from DP Pool in VSP external storage.

## Playbook: (ports_parameter_change_ext_storage.yml) [Change port mode setting, attribute setting, port security, fabric mode and port connection settings of the storage port]
This playbook is designed to Change port mode setting, attribute setting, port security, fabric mode and port connection settings of the storage port.

## Playbook: (storage_port_speed_auto.yml) [Change port speed to auto]
This playbook performs to change storage port speed set to auto.

## Playbook: (hostgroup_create_ldev_mapp_ext_storage.yml) [Create host group and map LDEV in external storage port]
This playbook performs to create host group and map created LDEV in external storage port by port ID.

## Playbook: (external_ports_required_parameters_change_local_storage.yml) [Change external port attribute required for UVM in local storage]
This playbook performs to change external port attribute required for UVM in local storage.

## Playbook: (external_Parity_Group_create_with_ALL_ext_path_for_Ldevs.yml) [Create Parity Group with all external paths for discovered LDEVs ]
This playbook performs to create Parity Group with all external paths for discovered LDEVs.

## Playbook: (external_volume_ALL_get_local_storage.yml) [Get all external volumes in local storage]
This playbook performs to Get all external volumes information in local storage.

## Playbook: (external_path_group_ALL_info_local_storage.yml) [Get all external paths in local storage]
This playbook performs to get all external volumes information in local storage.

## Playbook: (external_path_group_specific_ID_info_local_storage.yml) [Get information on specific external path group ID in local storage]
This playbook performs to get information on specific external path group ID information in local storage.

## Playbook: (external_vol_create_in_local_storage.yml) [Create external volumes in local storage]
This playbook performs to create external volumes in local storage that discovered from external storage.

## Playbook: (pool_create_from_ext_ldev_local_storage.yml) [Create DP Pool from the created external volumes]
This playbook performs to create DP Pool from the created external volumes in local storage.

## Playbook: (local_storage_HOST_ports_required_parameter_change.yml) [Change the local storage ports attribute connected with host]
This playbook performs to change the local storage ports attribute connected with host.

## Playbook: (ldev_create_local_storage_from_DP.yml) [Create LDEV from the DP Pool in local storage ]
This playbook performs to create LDEV from the DP Pool in local storage.

## Playbook: (hostgroup_create_both_ports_local_storage.yml) [Create hostgroup in local storage]
This playbook performs to create hostgroups in local storage.

## Playbook: (storage_port_details_with_hostgroup_ldevs.yml) [Get information on the host groups, LDEVs on storage port]
Get information on the host groups, LDEVs on specific storage port.

# **DISCLAIMER: **
All materials provided in this repository, including but not limited to Ansible Playbooks and Terraform Configurations, are made available as a courtesy. These materials are intended solely as examples, which may be utilized in whole or in part. Neither the contributors nor the users of this platform assert or are granted any ownership rights over the content shared herein. It is the sole responsibility of the user to evaluate the appropriateness and applicability of the materials for their specific use case.
Use of the material is at the sole risk of the user and the material is provided “AS IS,” without warranty, guarantees, or support of any kind, including, but not limited to, the implied warranties of merchantability, fitness for a particular purpose, and non-infringement. Unless specified in an applicable license, access to this material grants you no right or license, express or implied, statutorily or otherwise, under any patent, trade secret, copyright, or any other intellectual property right of Hitachi Vantara LLC (“HITACHI”). HITACHI reserves the right to change any material in this document, and any information and products on which this material is based, at any time, without notice. HITACHI shall have no responsibility or liability to any person or entity with respect to any damages, losses, or costs arising from the materials contained herein.
