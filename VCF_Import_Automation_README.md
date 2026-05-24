# hv-playbooks-HIS-VMWare

Ansible automation playbooks for end-to-end Hitachi VSP storage provisioning, Brocade FC zoning, VMware ESXi storage discovery, VMFS datastore creation, and VCSA 9.x deployment.

---

## Table of Contents

- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Recommended Workflow](#recommended-workflow)
- [Playbooks](#playbooks)
  - [1. storage\_provisioning](#1-storage_provisioning)
  - [2. brocade-zoning](#2-brocade-zoning)
  - [3. scan\_hba](#3-scan_hba)
  - [4. datastore\_create](#4-datastore_create)
  - [5. vcsa\_deploy](#5-vcsa_deploy)
  - [6. vSphere\_Import\_to\_VCF\_playbook](#6-vsphere_import_to_vcf_playbook)
- [Security — Ansible Vault](#security--ansible-vault)
- [Collections & Python Dependencies](#collections--python-dependencies)

---

## Overview

These playbooks automate the complete storage-to-VMware provisioning pipeline for Hitachi Infrastructure Services (HIS) environments:

| Step | Playbook | Purpose |
|------|----------|---------|
| 1 | `storage_provisioning` | Register VMware server on Hitachi VSP and provision a shared volume |
| 2 | `brocade-zoning` | Create FC alias, zone, and activate configuration on Brocade G720 |
| 3 | `scan_hba` | Rescan HBAs on ESXi and discover the newly presented LUN's canonical name |
| 4 | `datastore_create` | Create a VMFS datastore on the discovered device |
| 5 | `vcsa_deploy` | Deploy VCSA 9.x and configure Datacenter, Cluster, VDS, and Port Group |
| — | `vSphere_Import_to_VCF_playbook` | Standalone flat Brocade G720 zoning playbook (alternative to step 2) |

---

## Repository Structure

```
hv-playbooks-HIS-VMWare/
├── requirements.yml                          # Ansible Galaxy collections
│
├── storage_provisioning/
│   ├── site.yml                              # Entry point
│   ├── inventories/
│   │   └── fabric.yml                        # Hitachi VSP host definition
│   ├── global_vault/
│   │   └── vcf_vault.yml                     # VSP credentials (Vault-encrypted)
│   └── roles/hv_server_volume/tasks/
│       └── main.yml                          # Server registration + volume tasks
│
├── brocade-zoning/
│   ├── playbook.yml                          # Entry point
│   ├── inventory/
│   │   └── hosts.yml                         # Switch host + zoning parameters
│   └── roles/brocade_zoning/tasks/
│       └── main.yml                          # Alias, zone, cfg tasks
│
├── scan_hba/
│   ├── site.yml                              # Entry point
│   ├── inventories/
│   │   └── vmware_hosts.yml                  # ESXi host definition
│   ├── group_vars/
│   │   └── all.yml                           # ESXi credentials (Vault-encrypted)
│   └── roles/vmware_storage_scan/tasks/
│       └── main.yml                          # HBA rescan + disk discovery tasks
│
├── datastore_create/
│   ├── site.yml                              # Entry point
│   ├── inventories/
│   │   └── vmware_hosts.yml                  # ESXi host definition
│   └── group_vars/
│       └── all.yml                           # ESXi credentials (Vault-encrypted)
│
└── vcsa_deploy/
    ├── vcsa_deploy.yml                       # Entry point (2-stage play)
    ├── vmware_inventory.yml                  # Localhost inventory
    └── roles/vcf_vmware/templates/
        └── vcsa_deploy_config.json.j2        # VCSA deployment JSON template

vSphere_Import_to_VCF_playbook.yml.yml        # Standalone flat Brocade zoning playbook
```

---

## Prerequisites

### Controller Node

- Ansible ≥ 2.14
- Python 3.9+
- `pyVmomi` installed:
  ```bash
  pip install pyVmomi --break-system-packages
  ```
- Python virtual environment (recommended):
  ```bash
  python3 -m venv /home/ansibleadmin/ansible-venv
  source /home/ansibleadmin/ansible-venv/bin/activate
  ```

### Ansible Collections

Install all required collections at once from the root of the repository:

```bash
ansible-galaxy collection install -r requirements.yml
```

Collections installed:

| Collection | Purpose |
|------------|---------|
| `brocade.fos` | Brocade FOS switch automation |
| `community.vmware` ≥ 4.0.0 | VMware ESXi / vCenter modules |
| `hitachivantara.vspone_block` | Hitachi VSP One Block storage automation |

### Network Access

| Playbook | Target | Port |
|----------|--------|------|
| `storage_provisioning` | Hitachi VSP management IP | 443 |
| `brocade-zoning` | Brocade G720 management IP | 443 |
| `scan_hba` / `datastore_create` | ESXi management IP | 443 |
| `vcsa_deploy` Stage 1 | ESXi management IP | 443 |
| `vcsa_deploy` Stage 2 | vCenter (VCSA) IP | 443 |

---

## Recommended Workflow

Run the playbooks in this order for a full end-to-end provisioning:

```
[Hitachi VSP]           storage_provisioning   →  Register server + create volume
    ↓
[Brocade G720]          brocade-zoning         →  Zone LUN to ESXi host
    ↓
[VMware ESXi]           scan_hba               →  Rescan HBAs, get canonical name
    ↓
[VMware ESXi]           datastore_create       →  Create VMFS datastore
    ↓
[VCSA Deployment]       vcsa_deploy            →  Deploy vCenter + configure DC/Cluster/VDS
```

---

## Playbooks

---

### 1. storage_provisioning

**Purpose:** Registers a VMware server on a Hitachi VSP system, creates a shared volume with deduplication/compression, and attaches the volume to the server over Fibre Channel.

**Location:** `storage_provisioning/`

**Vault file:** `global_vault/vcf_vault.yml`

```yaml
storage_ip:       "your-vsp-ip"
storage_username: "your-vsp-username"
storage_password: "your-vsp-password"
```

**Usage:**

```bash
ansible-playbook -i inventories/fabric.yml site.yml --ask-vault-pass
```

**Runtime Prompts:**

| Prompt | Description |
|--------|-------------|
| `server_name` | Nickname for the VMware server on VSP |
| `hba_wwn1` | First HBA World Wide Name |
| `hba_wwn2` | Second HBA World Wide Name |
| `port_ids` | Comma-separated FC port IDs (e.g. `CL3-A,CL4-A`) |
| `pool_id` | VSP pool ID for volume creation |
| `volume_size` | Volume capacity (e.g. `100GB`) |
| `volume_base_name` | Base name for the volume |
| `capacity_saving` | `compression` / `deduplication` / `deduplication_and_compression` |
| `capacity_saving_status` | `enabled` / `disabled` |
| `data_reduction_share` | `true` / `false` |

**Workflow Tasks:**
1. Register VMware server with dual HBAs and FC paths
2. Save registered server ID
3. Create shared volume with capacity saving settings
4. Save created volume ID
5. Attach volume to the registered server

---

### 2. brocade-zoning

**Purpose:** Automates Fibre Channel zoning on Brocade G720 switches — creates a server alias, builds a zone, adds it to an existing zone configuration, and activates it.

**Location:** `brocade-zoning/`

**Inventory:** `inventory/hosts.yml`

Key parameters defined per switch host:

| Parameter | Description |
|-----------|-------------|
| `ansible_host` | Switch management IP |
| `fid` | Virtual Fabric ID (VFID) |
| `server_alias` | Alias name for the server host port |
| `server_wwpn` | Server WWPN mapped to the alias |
| `storage_alias` | Existing storage alias on the switch |
| `zone_name` | Name for the new FC zone |
| `cfg_name` | Existing zone configuration to update |
| `log_file` | Log output path |

**Usage:**

```bash
ansible-playbook playbook.yml -i inventory/hosts.yml
```

Credentials (`switch_user`, `switch_password`) are prompted interactively at runtime — they are not stored in any file.

**Workflow Tasks:**
1. Create server alias mapped to its WWPN
2. Create zone containing server and storage aliases
3. Add zone to existing configuration and activate it

---

### 3. scan_hba

**Purpose:** Rescans HBAs on a VMware ESXi host to refresh storage visibility after FC zoning, then collects and displays all discovered storage devices (device name, UUID, capacity) to identify the canonical name for datastore creation.

**Location:** `scan_hba/`

**Vault file:** `group_vars/all.yml`

```yaml
esxi_username: "your-esxi-username"
esxi_password: "your-esxi-password"
```

**Inventory:** `inventories/vmware_hosts.yml`

| Parameter | Description |
|-----------|-------------|
| `esxi_hostname` | ESXi management IP |
| `esxi_validate_certs` | SSL cert validation (`false` for self-signed) |
| `ansible_python_interpreter` | Path to Python in virtual environment |

**Usage:**

```bash
ansible-playbook -i inventories/vmware_hosts.yml site.yml --ask-vault-pass
```

**Workflow Tasks:**
1. Rescan HBAs and refresh storage visibility
2. Retrieve physical disk details via `vmware_host_disk_info`
3. Display all discovered storage devices (Device, UUID, SizeGB)

> **Output:** Note the `display_name` / canonical name of the newly presented LUN — it is required as input for the `datastore_create` playbook.

---

### 4. datastore_create

**Purpose:** Creates a VMFS datastore on a VMware ESXi host using the canonical device name discovered from the `scan_hba` playbook.

**Location:** `datastore_create/`

**Vault file:** `group_vars/all.yml`

```yaml
esxi_username: "your-esxi-username"
esxi_password: "your-esxi-password"
```

**Inventory:** `inventories/vmware_hosts.yml`

| Parameter | Description |
|-----------|-------------|
| `esxi_hostname` | ESXi management IP |
| `esxi_validate_certs` | SSL cert validation (`false` for self-signed) |

**Usage:**

```bash
ansible-playbook -i inventories/vmware_hosts.yml site.yml --ask-vault-pass
```

**Runtime Prompts:**

| Prompt | Description |
|--------|-------------|
| `datastore_name` | Name for the new VMFS datastore |
| `vmfs_device_name` | Canonical device name from `scan_hba` output |

**Workflow Tasks:**
1. Create VMFS datastore on the specified device using `community.vmware.vmware_host_datastore`

---

### 5. vcsa_deploy

**Purpose:** Deploys VMware vCenter Server Appliance (VCSA) 9.x to a standalone ESXi host using the official `vcsa-deploy` CLI. After deployment, configures vCenter with a Datacenter, Cluster, Virtual Distributed Switch (VDS), and a VLAN Port Group.

**Location:** `vcsa_deploy/`

**Vault file:** `ansible_vault_vmware_var.yml` *(must be created and encrypted manually)*

Expected vault variables include:

| Variable | Description |
|----------|-------------|
| `vcsa_ip` | VCSA target IP address |
| `vcsa_sso_user` | SSO administrator username |
| `vcsa_sso_password` | SSO administrator password |
| `vcenter_datacenter` | Datacenter name (e.g. `HIS-DC`) |
| `vcenter_cluster` | Cluster name (e.g. `ANS-clust`) |
| `vcenter_vds_name` | VDS name (e.g. `vDS-Main`) |
| `vcenter_vds_mtu` | VDS MTU (e.g. `1500`) |
| `vcenter_vds_uplinks` | Number of uplinks (e.g. `2`) |
| `vcenter_pg_name` | Port Group name (e.g. `VLAN-440`) |
| `vcenter_pg_vlan` | VLAN ID (e.g. `440`) |

**VCSA ISO — Mount Before Running:**

```bash
sudo mkdir -p /mnt/vcsa-iso
sudo mount -o loop VMware-VCSA-all-9.0.1.0.24957454.iso /mnt/vcsa-iso
```

**Usage:**

```bash
ansible-playbook -i vmware_inventory.yml vcsa_deploy.yml --ask-vault-pass
```

**Workflow — Stage 1 (VCSA VM Deployment):**
1. Verify ISO is mounted and `vcsa-deploy` binary exists
2. Render VCSA deployment JSON config from Jinja2 template
3. Run `vcsa-deploy install` (takes 30–60 minutes)
4. Remove temporary config file (contains passwords)
5. Wait for vCenter HTTPS API to become reachable on port 443

**Workflow — Stage 2 (vCenter Configuration):**
1. Create Datacenter
2. Create Cluster inside the Datacenter
3. Create Virtual Distributed Switch (VDS)
4. Create VLAN Port Group on the VDS

> **Note:** Stage 2 begins automatically after Stage 1 completes. The controller must be able to reach the VCSA IP on port 443.

---

### 6. vSphere_Import_to_VCF_playbook

**Purpose:** A standalone, flat (non-role-based) Brocade G720 FC zoning playbook. Performs the same three zoning operations as `brocade-zoning/` — creates a server alias, builds a zone, and activates the configuration — but with all tasks defined inline in a single file. Suitable for one-off runs or environments where the full role-based structure is not needed.

**File:** `vSphere_Import_to_VCF_playbook.yml.yml`

**Inventory:** Inline in playbook header comments — create `inventory/hosts.yml` manually:

```yaml
all:
  children:
    brocade_switches:
      hosts:
        switch01:
          ansible_host: 172.23.55.27
          fid: 128
          server_alias: "J02-U5-6-HA820G3-ANS"
          server_wwpn: "10:00:94:40:c9:d0:95:30"
          storage_alias: "B85-70-26-3A"
          zone_name: "J02-U5-6-HA820G3-ANS-B85-70-26-3A"
          cfg_name: "cfg20260218-RM"
          log_file: "/var/log/brocade_zoning.log"
```

**Usage:**

```bash
ansible-playbook vSphere_Import_to_VCF_playbook.yml.yml \
  -i inventory/hosts.yml --ask-vault-pass
```

Credentials (`switch_user`, `switch_password`) are prompted interactively at runtime.

**Workflow Tasks:**
1. Create server alias mapped to its WWPN
2. Create zone containing server and storage aliases
3. Add zone to existing configuration and activate it

**Comparison with `brocade-zoning/`:**

| | `vSphere_Import_to_VCF_playbook` | `brocade-zoning/` |
|---|---|---|
| Structure | Flat single file | Role-based |
| `gather_facts` | `yes` | `false` |
| Module style | Unqualified `debug:` | `ansible.builtin.debug:` |
| Recommended for | Quick one-off runs | Standard pipeline use |

---

## Security — Ansible Vault

All credential files must be encrypted with Ansible Vault before committing to version control.

| File | Playbook | Contains |
|------|----------|----------|
| `storage_provisioning/global_vault/vcf_vault.yml` | storage_provisioning | Hitachi VSP credentials |
| `scan_hba/group_vars/all.yml` | scan_hba | ESXi credentials |
| `datastore_create/group_vars/all.yml` | datastore_create | ESXi credentials |
| `vcsa_deploy/ansible_vault_vmware_var.yml` | vcsa_deploy | ESXi + VCSA credentials + config |

**Encrypt a vault file:**

```bash
ansible-vault encrypt <path-to-file>
```

**Edit an encrypted vault file:**

```bash
ansible-vault edit <path-to-file>
```

Brocade switch credentials (`switch_user`, `switch_password`) are prompted interactively at runtime and are never written to disk.

---

## Collections & Python Dependencies

All collections are declared in `requirements.yml` at the repository root.

**Install collections:**

```bash
ansible-galaxy collection install -r requirements.yml
```

**Install Python dependencies:**

```bash
pip install pyVmomi --break-system-packages
```

| Dependency | Required By |
|------------|-------------|
| `brocade.fos` | brocade-zoning |
| `community.vmware` ≥ 4.0.0 | scan_hba, datastore_create, vcsa_deploy |
| `hitachivantara.vspone_block` | storage_provisioning |
| `pyVmomi` (Python) | scan_hba, datastore_create |
