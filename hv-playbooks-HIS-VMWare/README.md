# hv-playbooks-HIS-VMWare

This project is a collection of Ansible playbooks designed to automate the end-to-end storage provisioning and VMware infrastructure setup pipeline for Hitachi Infrastructure Services (HIS) environments. It covers the full lifecycle starting from provisioning storage on a Hitachi VSP system — registering VMware servers, creating and attaching shared volumes — through Brocade G720 Fibre Channel switch zoning to map the storage to ESXi hosts, followed by HBA rescanning on VMware ESXi to discover newly presented LUNs, and VMFS datastore creation on those devices. The pipeline also includes the automated deployment and configuration of VMware vCenter Server Appliance (VCSA) 9.x, and the import of an existing vCenter and NSX environment into VCF 9.0.1 as a VI Workload Domain. Together, these playbooks eliminate manual steps across the storage, networking, and virtualization layers, enabling a repeatable and secure provisioning workflow using Ansible Vault for credential management and the `brocade.fos`, `community.vmware`, and `hitachivantara.vspone_block` collections.

---

## Table of Contents

- [Repository Structure](#repository-structure)
- [Playbooks Overview](#playbooks-overview)
- [Recommended Workflow](#recommended-workflow)
- [Prerequisites](#prerequisites)
- [Collections & Python Dependencies](#collections--python-dependencies)
- [Security — Ansible Vault](#security--ansible-vault)

---

## Repository Structure

```
hv-playbooks-HIS-VMWare/
├── requirements.yml
│
├── storage_provisioning/
│   ├── site.yml
│   ├── inventories/fabric.yml
│   ├── global_vault/vcf_vault.yml
│   └── roles/hv_server_volume/tasks/main.yml
│
├── brocade-zoning/
│   ├── playbook.yml
│   ├── inventory/hosts.yml
│   └── roles/brocade_zoning/tasks/main.yml
│
├── scan_hba/
│   ├── site.yml
│   ├── inventories/vmware_hosts.yml
│   ├── group_vars/all.yml
│   └── roles/vmware_storage_scan/tasks/main.yml
│
├── datastore_create/
│   ├── site.yml
│   ├── inventories/vmware_hosts.yml
│   └── group_vars/all.yml
│
├── vcsa_deploy/
│   ├── vcsa_deploy.yml
│   ├── vmware_inventory.yml
│   └── roles/vcf_vmware/templates/vcsa_deploy_config.json.j2
│
└── vsphere_Import_to_VCF9.0.1_Playbook.yml
```

---

## Playbooks Overview

| # | Playbook | Purpose | Individual README |
|---|----------|---------|-------------------|
| 1 | `storage_provisioning` | Register VMware server on Hitachi VSP and provision a shared volume | [README-storage-provisioning.md](README-storage-provisioning.md) |
| 2 | `brocade-zoning` | Create FC alias, zone, and activate configuration on Brocade G720 | [README-brocade-zoning.md](README-brocade-zoning.md) |
| 3 | `scan_hba` | Rescan HBAs on ESXi and discover newly presented LUN canonical names | [README-scan-hba.md](README-scan-hba.md) |
| 4 | `datastore_create` | Create a VMFS datastore on the discovered device | [README-datastore-create.md](README-datastore-create.md) |
| 5 | `vcsa_deploy` | Deploy VCSA 9.x and configure Datacenter, Cluster, VDS, and Port Group | [README-vcsa-deploy.md](README-vcsa-deploy.md) |
| 6 | `vsphere_Import_to_VCF9.0.1_Playbook` | Import existing vCenter + NSX into VCF 9.0.1 as a VI Workload Domain | [README-vsphere-import-to-vcf.md](README-vsphere-import-to-vcf.md) |

---

## Recommended Workflow

```
[Hitachi VSP]        storage_provisioning               →  Register server + create & attach volume
      ↓
[Brocade G720]       brocade-zoning                     →  Zone LUN to ESXi host via FC
      ↓
[VMware ESXi]        scan_hba                           →  Rescan HBAs, discover canonical name
      ↓
[VMware ESXi]        datastore_create                   →  Create VMFS datastore on LUN
      ↓
[VCSA Deployment]    vcsa_deploy                        →  Deploy vCenter + configure DC/Cluster/VDS
      ↓
[VCF 9.0.1]          vsphere_Import_to_VCF9.0.1         →  Import vCenter + NSX as VI Workload Domain
```

---

## Prerequisites

- Ansible ≥ 2.14
- Python 3.9+
- Python virtual environment (recommended):
  ```bash
  python3 -m venv /home/ansibleadmin/ansible-venv
  source /home/ansibleadmin/ansible-venv/bin/activate
  ```
- `sshpass` installed on controller (required by `vsphere_Import_to_VCF9.0.1_Playbook`)
- VCSA ISO mounted before running `vcsa_deploy`:
  ```bash
  sudo mkdir -p /mnt/vcsa-iso
  sudo mount -o loop VMware-VCSA-all-9.0.1.0.24957454.iso /mnt/vcsa-iso
  ```

### Network Access

| Playbook | Target | Port |
|----------|--------|------|
| `storage_provisioning` | Hitachi VSP management IP | 443 |
| `brocade-zoning` | Brocade G720 management IP | 443 |
| `scan_hba` / `datastore_create` | ESXi management IP | 443 |
| `vcsa_deploy` Stage 1 | ESXi management IP | 443 |
| `vcsa_deploy` Stage 2 | vCenter (VCSA) IP | 443 |
| `vsphere_Import_to_VCF9.0.1_Playbook` | SDDC Manager IP | 22 (SSH) |

---

## Collections & Python Dependencies

Install all collections before running any playbook:

```bash
ansible-galaxy collection install -r requirements.yml
pip install pyVmomi --break-system-packages
```

| Dependency | Required By |
|------------|-------------|
| `brocade.fos` | brocade-zoning |
| `community.vmware` ≥ 4.0.0 | scan_hba, datastore_create, vcsa_deploy |
| `hitachivantara.vspone_block` | storage_provisioning |
| `pyVmomi` (Python) | scan_hba, datastore_create |

---

## Security — Ansible Vault

All credential files must be encrypted before committing to version control:

```bash
ansible-vault encrypt <path-to-file>
ansible-vault edit <path-to-file>
```

| Vault File | Playbook | Contains |
|------------|----------|----------|
| `storage_provisioning/global_vault/vcf_vault.yml` | storage_provisioning | Hitachi VSP credentials |
| `scan_hba/group_vars/all.yml` | scan_hba | ESXi credentials |
| `datastore_create/group_vars/all.yml` | datastore_create | ESXi credentials |
| `vcsa_deploy/ansible_vault_vmware_var.yml` | vcsa_deploy | ESXi + VCSA credentials |
| `var_vault.yml` | vsphere_Import_to_VCF9.0.1_Playbook | SDDC Manager + vCenter credentials |

> Brocade switch credentials are prompted interactively at runtime and never stored on disk.
