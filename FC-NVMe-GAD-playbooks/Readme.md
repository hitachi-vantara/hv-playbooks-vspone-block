# Playbooks for End-to-End FC-NVMe GAD Pair Configuration. 

## Overview

These Ansible playbooks were customized to align with the environment’s specific requirements. 
These modified playbooks were then executed to automate the configuration of FC-NVMe GAD pairs, ensuring consistent, efficient, and error-free deployment of active-active volume replication across the connected storage systems.

The configuration was completed by executing the following tasks, with playbooks mentioned below:

**Get DP Pool:**
Collect facts about existing DP pools on both primary and secondary storage systems using get_storage_pool.yml.

**Get Parity Group:**
Retrieve parity group information to check health and capacity before DP pool creation with get_parity_group.yml.

**DP Pool Creation:**
Provision DP Pools on both storage systems for virtual volume creation using create_dp_pool.yml.

**Get LDEV Status:**
Check existing LDEV IDs and availability using get_ldev.yml.

**Virtual Volume Creation:**
Create virtual volumes (P-Vol) from the DP pool with create_virtual_vol.yml.

**Get Storage Port Info:**
Gather storage port details via port ID using get_port_info_byid.yml.

**Change Port Properties:**
Modify port mode and security from SCSI to NVMe using storage_port_change.yml.

**Add HBA WWN to Port:**
Add the host’s HBA WWN to the storage port default host group using add_wwn_storageport.yml.

**Get NVM Subsystem:**
Retrieve available NVM subsystems and check for free IDs with get_all_subsystem.yml.

**Create NVM Subsystem:**
Create a new NVM subsystem using a free ID with create_nvmsubsystem.yml.
***Note:*** _Omit namespace for secondary storage as it’s auto-assigned during GAD pair creation with NVMe namespace._

**Create Resource Group & Reserve Subsystem ID:**
Create a resource group on secondary storage using the primary’s serial number and model as virtual identifiers and reserve the NVM Subsystem ID. Done with create_rg_add_nvmsubsystem.yml.

**Create Remote Connection:**
Establish bidirectional remote connections between primary and secondary storage systems. Used create_remote_connection.yml.

**Create host group on external storage:**
Create a host group on the external storage port, mapping the LDEV (as external volume) and the WWNs of primary and secondary storage ports using create_hostgroup_with_ldev_wwn.yml.

**Create External Volumes & Add Quorum Disk:**
Create virtual external volumes using external storage capacity for quorum disks on both systems using create_external_vol.yml and add_quorum_disk.yml.
***Note:*** _The external path must be manually created in advance to provision external volumes using the playbook, as the module for external path creation is currently out of scope._

**Create GAD Pair:**
Create a GAD pair on the volumes with a namespace defined for NVMe-oF using create_gad_nvme_pair.yml. 

## Run and Troubleshoot ansible playbooks

###Execute a playbook task using this command syntax:
>ansible-playbook &lt;name of the yml file&gt;

###To get detailed output, run the playbook with verbose mode using the following syntax:
>ansible-playbook &lt;name of the yml file&gt; -vvv

###To troubleshoot issues, refer to the log file located at:
>$HOME/logs/hitachivantara/ansible/vspone_block/hv_vspone_block_modules.log
