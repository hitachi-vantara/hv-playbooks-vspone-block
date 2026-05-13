# Ansible Playbook: Bulk creation of multiple UR pairs
# Overview
Simplify large-scale Hitachi Universal Replicator (UR) pair provisioning with Red Hat Ansible automation. In environments where hundreds of HUR pairs need to be created—such as 128 or 256 pairs—provisioning each pair individually using the hv_hur module can be both time-consuming and inefficient. To address this challenge, Hitachi Vantara Automation introduces the "hv_hur_bulk" module, which is specifically designed for high-volume HUR pair creation. This Ansible Playbook enables batch provisioning of multiple HUR pairs based on parameters defined in a user-supplied variable file, including the number of pairs to create, start and end LDEV IDs, capacity saving settings, preconfigured host groups, and journal assignments. During execution, the playbook dynamically applies these inputs to automate the end-to-end provisioning process, significantly reducing deployment time and simplifying large-scale disaster recovery configuration.

# Test Environment
Below diagram depicts a standard UR configuration with 128 UR pairs and 2x Journal Groups.

![Remote Replication Diagram](./assets/HUR_Replication.png)

# Prerequisite
•	Establish Fibre Channel (FC) zoning between the two storage systems and host and primary storage system.

•	Ensure that Ansible is already configured and the local and remote VSP storage systems are registered with each other. 

•	Remote path is established between MCU and RCU (Refer to the playbook, https://github.com/hitachi-vantara/hv-playbooks-vspone-block/tree/main/create-multiple-remote-paths)

•	Host groups for P-Vols and S-Vols are already provisioned.

•	Journals are created and copy pace set to Medium. (Refer to the playbook, https://github.com/hitachi-vantara/hv-playbooks-vspone-block/tree/main/create-HUR-journals)

•	A standard variable file for storage credentials (“_ansible_vault_storage_var.yml_”) is created as shown below:

```
storage_serial: <primarySerialNumber>
storage_address: <StorageManagementAddress>
vault_storage_username: <username>
vault_storage_secret: <password>

secondary_storage_serial: <secondarySerialNumber>
secondary_storage_address: <StorageManagementAddress> 
vault_secondary_storage_username: <username>
vault_secondary_storage_secret: <password>
```

# Execution
**Sample Output:**
