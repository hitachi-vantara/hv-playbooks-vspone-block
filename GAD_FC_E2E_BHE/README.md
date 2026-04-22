# Playbook for End-to-End FC GAD Pair Configuration

## Overview

This Ansible playbook was customized to align with the environment's specific requirements. This modified playbook is executed to automate the full end-to-end configuration of FC GAD pairs, ensuring consistent, efficient, and error-free deployment of active-active volume replication across connected storage systems. All configuration parameters are externalized into a variables file (`pre_provision_vars_bhe.yml`), allowing teams to adjust values without modifying the playbook logic.

The configuration is completed by executing the following tasks in sequence:

**Create Storage Pool on MCU:** Using provided spec including name, pool type, pool ID, and pool volumes (parity group and capacity) a storage pool is created on the MCU storage array using the hv_storagepool module.

**Create Storage Pool on RCU:** Using provided spec including name, pool type, pool ID, and pool volumes (parity group and capacity) a storage pool is created on the RCU storage array using the hv_storagepool module.

**Gather Existing LDEVs in Specified Range:** Using provided spec including start LDEV ID and end LDEV ID, the hv_ldev_facts module gathers all existing LDEVs within the specified range on the MCU. This is used to determine which LDEVs need to be created.

**Create Missing LDEVs:** Using provided spec including ldev_id, pool_id, size, name prefix, and data_reduction_share the playbook loops over the LDEV range and creates only those LDEVs that do not already exist, using the hv_ldev module. Data reduction sharing is enabled by default for all created LDEVs.

**Set New LDEVs Variable:** Registers only the successfully created LDEVs (where changes occurred) from the previous task into a variable for use in subsequent tasks.

**Calculate LDEV Batches for Host Group Mapping:** Calculates LDEV batches to evenly distribute the newly created LDEVs across the defined host groups. The batch size is determined by dividing the total number of new LDEVs by the number of host groups.

**Create Host Groups with Assigned LDEVs on MCU:** Using provided spec including name, port, host mode, LDEVs, and WWNs, host groups are created on the MCU with their assigned LDEV batches using the hv_hg module. This task is skipped if no new LDEVs were created or if a given batch is empty.

**Create Host Group on RCU:** Using provided spec including name, port, and host_mode a host group is created on the RCU storage array using the hv_hg module. This host group is required for GAD pair creation on the secondary side.

**Validate Virtual Serial Number Format:** The playbook validates that the provided virtual_serial_number is exactly 6 digits (including the model prefix digit). The assertion will fail the playbook if the format is incorrect, preventing misconfiguration downstream.

**Add Resources (VSM) to Resource Group with Idempotent Pre-Check:** The playbook retrieves all existing resource groups on the RCU and checks whether a Virtual Storage Machine (VSM) with the provided serial number already exists. The API stores the virtual serial number with the model prefix digit stripped (e.g., 970045 becomes 70045). Based on this check the playbook follows one of two paths:

- **Path A (VSM does not exist):** A new resource group is created with the full VSM configuration including the virtual storage serial, virtual storage model, secondary port, and secondary host group using the hv_resource_group module.
- **Path B (VSM already exists):** The playbook checks whether the secondary port and host group are already present in the existing resource group. If the port is missing, it is added. If the host group is missing, it is added. If both are already present, the task is skipped with an informational message. This ensures GAD pair creation can proceed without the FA1B error.

**Register Quorum Disk on MCU:** Using provided spec including remote storage serial number, MCU storage type, LDEV ID for quorum, and quorum ID a quorum disk is registered on the MCU using the hv_quorum_disk module.

**Register Quorum Disk on RCU:** Using provided spec including remote storage serial number, RCU storage type, LDEV ID for quorum, and quorum ID a quorum disk is registered on the RCU using the hv_quorum_disk module.

> **Note:** The external path must be manually created in advance to provision external volumes using the playbook, as the module for external path creation is currently out of scope.

**Create Remote Connection on MCU:** Using provided spec including path group ID, remote storage serial number, remote paths (local and remote port pairs), minimum remote paths, remote I/O timeout in seconds, and round trip in milliseconds a remote connection is created on the MCU using the hv_remote_connection module.

**Create Remote Connection on RCU:** Using provided spec including path group ID, remote storage serial number, remote paths (local and remote port pairs), minimum remote paths, remote I/O timeout in seconds, and round trip in milliseconds a remote connection is created on the RCU using the hv_remote_connection module.

**Create GAD Pairs:** Using provided spec including primary storage serial number, secondary storage serial number, copy group name, copy pair name, primary volume ID, secondary pool ID, secondary host group name and port, quorum disk ID, and path group ID the playbook loops over all newly created LDEVs to create GAD pairs on both the MCU and RCU using the hv_gad module. This task is skipped if no new LDEVs were created.

**Build Consolidated Pre-Configuration Report:** A comprehensive report of the GAD configuration is generated that includes the existing LDEVs found in the specified range, the newly created LDEVs, host group creation details with associated LUN paths, and VSM/resource group status (whether newly created or pre-existing).

**Write Pre-Configuration Report to File:** The generated report is written to `/tmp/gad_pre_config_report.txt` for review and record keeping.

## Configurable Variables (pre_provision_vars_bhe.yml)

All configuration parameters are defined in `pre_provision_vars_bhe.yml` located in the same directory as the playbook. Below are the key configurable variables organized by function:

### Storage Pools

| Variable | Description |
|---|---|
| mcu_pool_name | Name of the storage pool on the MCU |
| mcu_pool_type | Pool type on the MCU (e.g., HDP) |
| mcu_pool_id | Pool ID on the MCU |
| mcu_pool_vols_list | List of parity groups and capacities for the MCU pool |
| rcu_pool_name | Name of the storage pool on the RCU |
| rcu_pool_type | Pool type on the RCU (e.g., HDP) |
| rcu_pool_id | Pool ID on the RCU |
| rcu_pool_vols_list | List of parity groups and capacities for the RCU pool |

### LDEVs and Volume Layout

| Variable | Description |
|---|---|
| ldev_start_id | Starting LDEV ID for the range |
| ldev_end_id | Ending LDEV ID for the range |
| ldev_name_prefix | Naming prefix for created LDEVs (suffix is the LDEV ID) |
| ldev_size | Size of each LDEV (e.g., 100MB) |
| host_groups | List of MCU host groups with name, port, host_mode, and WWNs |
| copy_group_name | Name of the GAD copy group |

### Secondary (RCU) Host Group

| Variable | Description |
|---|---|
| secondary_hg_name | Name of the host group on the RCU |
| secondary_port | Port for the RCU host group |

### Resource Group and VSM

| Variable | Description |
|---|---|
| rg_name | Name of the resource group on the RCU |
| virtual_serial_number | 6-digit virtual serial number including model prefix (e.g., 970045) |
| vsm_model | Virtual storage machine model (e.g., VSP_ONE_B85) |

### Quorum Configuration

| Variable | Description |
|---|---|
| mcu_quorum_id | Quorum disk ID on the MCU |
| mcu_quorum_ldev | LDEV ID used for quorum on the MCU |
| mcu_storage_type | Storage type for MCU quorum registration (e.g., R9) |
| rcu_quorum_id | Quorum disk ID on the RCU |
| rcu_quorum_ldev | LDEV ID used for quorum on the RCU |
| rcu_storage_type | Storage type for RCU quorum registration (e.g., R9) |

### Remote Connections

| Variable | Description |
|---|---|
| path_group_id | Path group ID for remote connections and GAD pairing |
| mcu_remote_paths_list | List of local/remote port pairs for the MCU remote connection |
| rcu_remote_paths_list | List of local/remote port pairs for the RCU remote connection |

To adjust configuration, edit `pre_provision_vars_bhe.yml` directly. No changes to the playbook are required.

## Prerequisites

- Ansible must be installed and configured on the control node.
- The Hitachi Vantara `vspone_block` Ansible collection must be installed.
- Vault variables file (`ansible_vault_storage_var_2.yml`) must be configured with valid storage credentials for both the MCU and RCU systems.
- `pre_provision_vars_bhe.yml` must be present in the same directory as the playbook.
- Network connectivity to both primary (MCU) and secondary (RCU) storage systems is required.
- External paths for quorum disk provisioning must be manually created in advance, as the external path creation module is currently out of scope.

