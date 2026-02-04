# Playbooks for iSCSI GAD Pair Configuration.

## Overview

These Ansible playbooks were customized to align with the environment’s specific requirements and were executed to automate the end-to-end configuration of iSCSI-based GAD pairs. This automation ensures a consistent, efficient, and reliable deployment of active-active volume replication across the connected Hitachi VSP One primary and secondary storage systems.

The configuration was completed by executing the following tasks, with the corresponding playbooks mentioned below:

**Get DP Pool & Parity Group:** Collect DP pool and parity group details to validate health and capacity on primary and secondary storage systems using get_pool_paritygrp_info.yml.

**Get Free LDEV IDs:** Identify available LDEV IDs on both storage systems for GAD pairing using get_free_ldevid_pri_sec.yml.

**DP Pool & DRS Volume Creation (Primary Storage):** Create DP pools and provision the DRS primary volume on the primary storage system using create_pool_DRSvol_pri.yml.

**Get Storage Port Info:** Retrieve storage port details for both primary and secondary systems using port IDs with get_port_info.yml.

**Configure iSCSI Port:** Configure iSCSI ports with the required parameters for host and remote connectivity using configure_iscsi_port.yml.

**Create iSCSI Target & Update Host Mode (Primary Storage):** Create an iSCSI target, attach the DRS volume, and update Host Mode and Host Mode Options using create_iscsitarget_addvol_update_HM_HMO_pri.yml.

**DP Pool Creation (Secondary Storage):** Create a DP pool on the secondary storage system using create_pool_sec.yml.

**Create iSCSI Target & Update Host Mode (Secondary Storage):** Create an iSCSI target with only the host IQN and update Host Mode and Host Mode Options using create_iscsitarget_update_HM_HMO_sec.yml.

**Create Resource Group & Reserve iSCSI Target (Secondary Storage):** Create a resource group using primary storage identifiers and reserve the iSCSI target using create_rg_with_iscsi_target.yml.

**Register Remote Storage:** Register the remote storage before establishing remote connections using register_remote_storage.yml.

**Create iSCSI Remote Connection:** Establish bidirectional remote connections by registering iSCSI ports and adding remote paths using iscsi_remote_connection.yml.

**Create External Volume, Host Group & Mapping on External Storage:** Create an external LDEV, configure host groups, and map the volume to primary and secondary storage WWNs using create_ldev_hostgrp_ext.yml.

**External Volume Addition & Quorum Disk Registration:** Add external volumes as quorum disks on both storage systems using external_vol_add.yml and quorum_disk_registration.yml.

**Create iSCSI GAD Pair:** Create the active-active iSCSI GAD pair between the primary and secondary storage systems using gad_pair_iscsi.yml.

## Run and Troubleshoot ansible playbooks

###Execute a playbook task using this command syntax:
>ansible-playbook &lt;name of the yml file&gt;

###To get detailed output, run the playbook with verbose mode using the following syntax:
>ansible-playbook &lt;name of the yml file&gt; -vvv

###To troubleshoot issues, refer to the log file located at:
>$HOME/logs/hitachivantara/ansible/vspone_block/hv_vspone_block_modules.log
>$HOME/logs/hitachivantara/ansible/vspone_block/hv_vspone_block_audit.log

