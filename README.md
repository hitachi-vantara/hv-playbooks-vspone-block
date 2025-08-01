# Ansible Playbooks for Hitachi VSP One Block storage systems

## Playbook: [Auto-Expand High-Utilization LDEVs](Volume_Ansible_RESTAPI)
This Ansible playbook is designed to monitor LDEVs (Logical Devices) on a Hitachi VSP subsystem, identify those that exceed **80% utilization**, automatically expand their volume by **10%**, and notify the storage administrator via email.
It is intended to be scheduled as a **cron job**, providing automated storage management and proactive capacity handling based on real-time usage.  See [Readme.txt](https://github.com/hitachi-vantara/hv-playbooks-vspone-block/tree/main/Volume_Ansible_RESTAPI#:~:text=Readme.txt) for more info.

## Playbook: [Storage_Jira_Python](Storage_Jira_Python)
This playbook automates the provisioning of LUNs (Logical Unit Numbers) by integrating Jira issue tracking with Ansible and Hitachi storage modules. It continuously polls Jira for new LUN requests, parses the required size, triggers an Ansible playbook to create the LDEV, and updates the Jira issue with the result.  See [Readme.txt](https://github.com/hitachi-vantara/hv-playbooks-vspone-block/tree/main/Storage_Jira_Python#:~:text=Readme.txt) for more info. 

## Playbook:  [Provision ldev to NVM Subsystem in VSM resource group](provision_ldev_to_nvm_subsystem_in_vsm.yml)
This playbook prepares the volume that must be presented to NVM subsystem in VSM.  Streamlines a multi-step process into a single automated action, saving time for storage administrators.
- Creating the LDEV
- Moving LDEV to VSM
- Presenting LDEV to NVM subsystem
The same provisioning steps can be reused and standardized across teams or environments. Applications or services can get storage instantly, rather than waiting on manual provisioning.

This plabyook creates an ldev with auto ldev id and of size provided in the spec, moves the ldev to the VSM and then present the ldev as namespace to given NVM subsystem.
 - User provides the Volume information and the NVME Subsystem Id
 - Create the ldev
 - Move ldev to VSM
 - Present ldev as namespace to NVM subsystem

## Playbook: [Delete GAD pair and SVOL](delete-fc-gad-and-delete-svol.yml)
This playbook performs SVOL clean up task post GAD pair deletion. Embedding this logic into a workflow ensures that every time a GAD pair is deleted, the cleanup is consistent. Manual deletion can lead to mistakes, like deleting the wrong volume. A workflow tied to the specific GAD pair helps target and delete only the correct s-vol, minimizing risk. Streamlines a multi-step process into a single automated action, saving time for storage administrators.  This playbook helps in moving the SVOL back to meta resource before deleting, so that ldev id can be used again.  

- Select the specific GAD pair
- Ensure the GAD pair is in a deletable state
- Delete GAD Pair and confirm deletion
- From the now-deleted pair, identify the s-vol and confirm it is no longer in a pair
- Optionally, un-map the volume if it is mapped.
- Move the volume back to Meta-resource
- Delete the volume

## Playbook: [End-to-End FC-NVMe GAD Pair Configuration](FC-NVMe-GAD-playbooks)
These Ansible playbooks are customized to automate the configuration of FC-NVMe GAD pairs, ensuring consistent, efficient, and error-free deployment of active-active volume replication across the connected storage systems.
 
_The setup was completed by executing a series of Ansible playbooks for the following tasks._
- Get DP Pool
- Get Parity Group
- DP Pool Creation
- Get LDEV Status
- Virtual Volume Creation
- Get Storage Port Info
- Change Port Properties
- Add HBA WWN to Port
- Get NVM Subsystem
- Create NVM Subsystem
- Create Resource Group & Reserve Subsystem ID
- Create Remote Connection
- Create Host Group on External Storage
- Create External Volumes & Add Quorum Disk
- Create GAD Pair

See [Readme.md](https://github.com/hitachi-vantara/hv-playbooks-vspone-block/tree/main/FC-NVMe-GAD-playbooks#:~:text=Readme.md) for more info.

## Playbook: [End-to-End TrueCopy Pair Configuration](true-copy-playbook)
These Ansible playbooks are customized to automate the configuration of TrueCopy pair across the connected storage systems.
 
The setup was completed by executing a series of Ansible playbooks for the following tasks:
- Change attribute setting of the storage port
- Change port mode setting of the storage port
- Change fabric mode and port connection settings of the storage port
- Change port speed and port security settings of the storage port
- Create a new remote connection
- Create Ldev
- Change security setting of the storage port
- Create hostgroup
- Create a TrueCopy pair
- Split TrueCopy pair
- Resync TrueCopy pair
- Delete TrueCopy pair

See [Readme.md](https://github.com/hitachi-vantara/hv-playbooks-vspone-block/blob/main/true-copy-playbook/Readme.md) for more info.


# **DISCLAIMER: **
All materials provided in this repository, including but not limited to Ansible Playbooks and Terraform Configurations, are made available as a courtesy. These materials are intended solely as examples, which may be utilized in whole or in part. Neither the contributors nor the users of this platform assert or are granted any ownership rights over the content shared herein. It is the sole responsibility of the user to evaluate the appropriateness and applicability of the materials for their specific use case.
Use of the material is at the sole risk of the user and the material is provided “AS IS,” without warranty, guarantees, or support of any kind, including, but not limited to, the implied warranties of merchantability, fitness for a particular purpose, and non-infringement. Unless specified in an applicable license, access to this material grants you no right or license, express or implied, statutorily or otherwise, under any patent, trade secret, copyright, or any other intellectual property right of Hitachi Vantara LLC (“HITACHI”). HITACHI reserves the right to change any material in this document, and any information and products on which this material is based, at any time, without notice. HITACHI shall have no responsibility or liability to any person or entity with respect to any damages, losses, or costs arising from the materials contained herein.
