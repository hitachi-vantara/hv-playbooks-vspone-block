# Ansible Playbook: Create Multiple Data Volumes With Host Paths
# Overview
An enterprise-class configuration typically requires a large number of volumes. The playbook, creates multiple volumes with specific parameters such as ADR, no-ADR, size, and naming.

# Test Environment
A sample data volume specification for remote replication is shown in below table.

| Data Volumes | P-Vols (MCU) | S-Vols (RCU) |
|---|---|---|
| Number of Volumes | 32 | <- |
| Pool ID and LDEV ID | Pool1: LDEV 0-15, Pool2: LDEV 16-31 | <-|
| ADR | Disabled | <- |
| Size | 100 GB | <- |
| Name Prefix | Data_Vols | <-|
| DRS | false | <- |


# Prerequisite
•	Establish Fibre Channel (FC) zoning between the server and storage system.

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
Create a “var.yml”, specify the MCU and RCU volumes, with each line representing the volumes assigned per pool. The file also defines Adaptive Data Reduction (ADR) options ("compression", "compression_deduplication", or "disabled"), default LDEV size, a naming prefix for volumes, and whether Data Reduction Share (DRS) is enabled or disabled for MCU and RCU volumes.


**Sample input for “var.yml” file:**
```
mcu_ldev:
  - "0-15,1"
  - "16-31,2"
rcu_ldev:
  - "0-15,1"
  - "16-31,2"
mcu_capacity_saving: "disabled"
rcu_capacity_saving: "disabled"
default_size: "100GB"
ldev_name_prefix: "Data_Vols"
mcu_DRS: "false"
rcu_DRS: "false"

```

Run the playbook with _ansible-playbook <playbook_name>_

This generates an output file as shown below.

**Sample output for LDEV creation:**
```
#cat /tmp/ldev_creation_report_20250913_142203.txt 
===================== LDEV Creation Report ==================

SN_"111111":
0: ["pool_id": 1, "provision_type": "CVS,HDP", "deduplication_compression_mode": "disabled", "capacity": "100.00GB" ]
1: ["pool_id": 1, "provision_type": "CVS,HDP", "deduplication_compression_mode": "disabled", "capacity": "100.00GB" ]
...
30: ["pool_id": 2, "provision_type": "CVS,HDP", "deduplication_compression_mode": "disabled", "capacity": "100.00GB" ]
31: ["pool_id": 2, "provision_type": "CVS,HDP", "deduplication_compression_mode": "disabled", "capacity": "100.00GB" ]

SN_"222222":
0: ["pool_id": 1, "provision_type": "CVS,HDP", "deduplication_compression_mode": "disabled", "capacity": "100.00GB" ]
1: ["pool_id": 1, "provision_type": "CVS,HDP", "deduplication_compression_mode": "disabled", "capacity": "100.00GB" ]
...
30: ["pool_id": 2, "provision_type": "CVS,HDP", "deduplication_compression_mode": "disabled", "capacity": "100.00GB" ]
31: ["pool_id": 2, "provision_type": "CVS,HDP", "deduplication_compression_mode": "disabled", "capacity": "100.00GB" ]
```

