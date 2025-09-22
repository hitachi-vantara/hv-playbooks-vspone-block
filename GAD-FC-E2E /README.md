# Playbooks for End-to-End FC GAD Pair Configuration. 

## Overview

These Ansible playbooks were customized to align with the environment’s specific requirements. 
These modified playbooks were then executed to automate the configuration of FC GAD pairs, ensuring consistent, efficient, and error-free deployment of active-active volume replication across the connected storage systems.

The configuration was completed by executing the following tasks, with playbooks mentioned below:

**Create Storage Pool on MCU:**
Using provided spec- name, pool type and pool volumes to create pool on MCU storage array.

**Create Storage Pool on RCU:**
Using provided spec- name, pool type and pool volumes to create pool on RCU storage array.


**Gather LDEVs in specified range:**
Using provided spec- start ldev and end ldev id and ldev facts module to gather existing ldevs.

**Create LDEVs:**
Using provided spec- ldev_id, pool_id, size and name it loops over ldev range to create ldevs using the ldev module.

**Set New LDEVs:**
Register successfully created ldevs from previous task.

**Calculate LDEV Batches for Host Group Mapping:**
Calculate ldev batches based on the number total host groups / ldevs get evenly distribute across host groups.



**Create Host Groups with Assigned LDEVs:**
Using provided spec- name, port, host mode, ldevs and wwns host groups are created from previous task using the hv hg module.


**Create host group on RCU**
Using provided spec- name, port and host_mode host groups are created using the hv hg module.


**Add Resources such as VSM to Resource Group:**
Using provided spec- resource group name, virtual serial number, virtual storage machine model a resource group is created using the hv resource group module.



**Register Quorum Disk on MCU **
Using provided spec- remote storage serial number, MCU storage type, ldev id for quorum and quorum id a quorum is created on the MCU using the hv quorum disk module.


**Register Quorum Disk on RCU:**
Using provided spec- remote storage serial number, RCU storage type, ldev id for quorum and quorum id a quorum is created on the RCU using the hv quorum disk module.
***Note:*** _The external path must be manually created in advance to provision external volumes using the playbook, as the module for external path creation is currently out of scope._

**Create remote connection on MCU**
Using provided spec- path group id, remote storage serial number, remote paths, minimum remote paths, remote io timeout in sec and round trip in msec a remote connection is created on the MCU using the hv remote connection module.



**Create remote connection on RCU**
Using provided spec- path group id, remote storage serial number, remote paths, minimum remote paths, remote io timeout in sec and round trip in msec a remote connection is created on the RCU using the hv remote connection module.


**Create GAD Pair:**
Using provided spec- primary storage serial number, secondary storage serial number, copy group name, copy pair name, primary volume id, secondary pool id, secondary host group name, secondary host group port, quorum disk id, path group id it loops over all ldevs to create GAD pairs on both the MCU and RCU using the hv gad module.



**Build Consolidated Pre-Config Report:**
A report of your GAD configuration is created that shows the existing ldevs, the created ldevs, host groups and GAD pairs.

## Run and Troubleshoot ansible playbooks

###Execute a playbook task using this command syntax:
>ansible-playbook &lt;name of the yml file&gt;

###To get detailed output, run the playbook with verbose mode using the following syntax:
>ansible-playbook &lt;name of the yml file&gt; -vvv

###To troubleshoot issues, refer to the log file located at:
>$HOME/logs/hitachivantara/ansible/vspone_block/hv_vspone_block_modules.log
