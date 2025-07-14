These Ansible playbooks were customized to align with the environment’s specific requirements. These modified playbooks were then executed to automate the configuration of TrueCopy pairs, ensuring consistent, efficient, and error-free deployment of remote replication across the connected storage systems.

## Playbook: (port_attribute.yml) [Change attribute setting of the storage port]
This Ansible playbook is designed to change attribute setting of the storage port by port id.

## Playbook: (port_mode.yml)[Change port mode setting of the storage port]
This playbook is designed to change port mode setting of the storage port by port id.

## Playbook: (port_connection_type.yml) [Change fabric mode and port connection settings of the storage port]
This playbook is designed to change fabric mode and port connection settings of the storage port by port id.

## Playbook: (port_speed_security.yml) [Change port speed and port security settings of the storage port]
This playbook performs to Change port speed and port security settings of the storage port by port id.

## Playbook: (port_security_disable.ymld) [Change port security to disable of the storage port]
This playbook performs to Change port security to disable of the storage port by port id.

## Playbook: (remote_path_create.yml) [Create a new remote connection]
This playbook performs to create a new remote path connection between primary storage and secondary storage.

## Playbook: (remote_path_status.yml) [Get all remote connection information]
This playbook performs to Get all remote connection information.

## Playbook: (ldev_create_using_pool_id.yml) [Create ldev with size mention]
This playbook performs to create ldev.

## Playbook: (port_security_enable.yml) [Change port security setting of the storage port]
This playbook performs to change port security setting of the storage port by port id.

## Playbook: (hostgroup_create.yml) [Create hostgroup]
This playbook performs to Create hostgroup on a storage port.

## Playbook: (truecopy_PAIR_create_TASK2.yml) [Create a TrueCopy pair by specifying few fields]
This playbook performs to create a TrueCopy pair by specifying all the fields like primary_volume_id, secondary_pool_id, secondary_hostgroup, fence_level, path_group_id, etc.

## Playbook: (truecopy_split.yml) [Split TrueCopy pair]
This playbook performs to split TrueCopy pair by specifying few required fields.

## Playbook: (truecopy_resync.yml) [Resync TrueCopy pair ]
This playbook performs to resync TrueCopy pair by copy_group_name and copy_pair_name.

## Playbook: (truecopy_PAIR_STATUS_TASK1.yml) [Get all TrueCopy pairs]
This playbook performs to get all TrueCopy pairs in a storage.

## Playbook: (truecopy_PAIR_delete_TASK15.yml) [Delete TrueCopy pair]
This playbook performs to delete TrueCopy pair by copy_group_name and copy_pair_name.

## Playbook: (remote_path_delete.yml) [Delete a remote connection]
This playbook performs to delete a remote connection by remote path id.


# **DISCLAIMER: **
All materials provided in this repository, including but not limited to Ansible Playbooks and Terraform Configurations, are made available as a courtesy. These materials are intended solely as examples, which may be utilized in whole or in part. Neither the contributors nor the users of this platform assert or are granted any ownership rights over the content shared herein. It is the sole responsibility of the user to evaluate the appropriateness and applicability of the materials for their specific use case.
Use of the material is at the sole risk of the user and the material is provided “AS IS,” without warranty, guarantees, or support of any kind, including, but not limited to, the implied warranties of merchantability, fitness for a particular purpose, and non-infringement. Unless specified in an applicable license, access to this material grants you no right or license, express or implied, statutorily or otherwise, under any patent, trade secret, copyright, or any other intellectual property right of Hitachi Vantara LLC (“HITACHI”). HITACHI reserves the right to change any material in this document, and any information and products on which this material is based, at any time, without notice. HITACHI shall have no responsibility or liability to any person or entity with respect to any damages, losses, or costs arising from the materials contained herein.
