# scan_hba

Rescans Host Bus Adapters (HBAs) on a VMware ESXi host to refresh storage visibility after Fibre Channel zoning, then retrieves and displays all discovered storage devices including device name, UUID, and capacity. The canonical name output from this playbook is used as direct input to the `datastore_create` playbook.

---

## Directory Structure

```
scan_hba/
├── site.yml                              # Entry point
├── inventories/
│   └── vmware_hosts.yml                  # ESXi host definition
├── group_vars/
│   └── all.yml                           # ESXi credentials (Vault-encrypted)
└── roles/
    └── vmware_storage_scan/
        └── tasks/
            └── main.yml                  # HBA rescan + disk discovery tasks
```

---

## Vault File

`group_vars/all.yml` — must be encrypted with Ansible Vault before committing:

```yaml
esxi_username: "your-esxi-username"
esxi_password: "your-esxi-password"
```

```bash
ansible-vault encrypt group_vars/all.yml
```

---

## Inventory

`inventories/vmware_hosts.yml`:

| Parameter | Description |
|-----------|-------------|
| `esxi_hostname` | ESXi management IP address |
| `esxi_validate_certs` | SSL cert validation (`false` for self-signed) |
| `ansible_python_interpreter` | Path to Python in virtual environment |

---

## Usage

```bash
ansible-playbook -i inventories/vmware_hosts.yml site.yml --ask-vault-pass
```

---

## Tasks

1. Rescan HBAs and refresh storage visibility on ESXi host
2. Retrieve physical disk details via `vmware_host_disk_info`
3. Dump raw disk info structure for debugging
4. Display all discovered storage devices (Device, UUID, SizeGB)

> **Note:** Record the `display_name` (canonical name) of the newly presented LUN from the output — it is required as input for `datastore_create`.

---

## Requirements

```bash
ansible-galaxy collection install community.vmware
pip install pyVmomi --break-system-packages
```
