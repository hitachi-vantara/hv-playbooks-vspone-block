# datastore_create

Creates a VMFS datastore on a VMware ESXi host using the canonical device name discovered from the `scan_hba` playbook. Prompts the user at runtime for the datastore name and target device — nothing is hardcoded.

---

## Directory Structure

```
datastore_create/
├── site.yml                              # Entry point
├── inventories/
│   └── vmware_hosts.yml                  # ESXi host definition
└── group_vars/
    └── all.yml                           # ESXi credentials (Vault-encrypted)
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

## Runtime Prompts

| Prompt | Description |
|--------|-------------|
| `datastore_name` | Name for the new VMFS datastore |
| `vmfs_device_name` | Canonical device name from `scan_hba` output |

---

## Tasks

1. Create VMFS datastore on the specified device using `community.vmware.vmware_host_datastore`

---

## Requirements

```bash
ansible-galaxy collection install community.vmware
pip install pyVmomi --break-system-packages
```
