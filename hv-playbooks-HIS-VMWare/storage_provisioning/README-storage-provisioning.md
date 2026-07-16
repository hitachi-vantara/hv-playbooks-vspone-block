# storage_provisioning

Automates server registration and volume provisioning on a Hitachi VSP storage system using the `hitachivantara.vspone_block` Ansible collection. Registers a VMware server with its HBAs and FC paths, creates a shared volume with configurable deduplication and compression, and attaches the volume to the registered server — all driven by runtime prompts with no hardcoded values.

---

## Directory Structure

```
storage_provisioning/
├── site.yml                              # Entry point
├── inventories/
│   └── fabric.yml                        # VSP host definition
├── global_vault/
│   └── vcf_vault.yml                     # VSP credentials (Vault-encrypted)
└── roles/
    └── hv_server_volume/
        └── tasks/
            └── main.yml                  # Server registration + volume tasks
```

---

## Vault File

`global_vault/vcf_vault.yml` — must be encrypted with Ansible Vault before committing:

```yaml
storage_ip:       "your-vsp-ip"
storage_username: "your-vsp-username"
storage_password: "your-vsp-password"
```

```bash
ansible-vault encrypt global_vault/vcf_vault.yml
```

---

## Usage

```bash
ansible-playbook -i inventories/fabric.yml site.yml --ask-vault-pass
```

---

## Runtime Prompts

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

---

## Tasks

1. Register VMware server with dual HBAs and FC paths on Hitachi VSP
2. Save registered server ID for subsequent steps
3. Create shared volume with capacity saving and data reduction settings
4. Save created volume ID
5. Attach the volume to the registered server

---

## Requirements

```bash
ansible-galaxy collection install hitachivantara.vspone_block
```
