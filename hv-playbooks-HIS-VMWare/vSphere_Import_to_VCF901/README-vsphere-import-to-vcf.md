# vsphere_Import_to_VCF9.0.1_Playbook

Imports an existing external vCenter Server and NSX deployment into VMware Cloud Foundation (VCF) 9.0.1 as a VI Workload Domain. The playbook SSHes into the SDDC Manager node and invokes the `vcf_brownfield.py` import tool, passing all required parameters and credentials via environment variables to avoid interactive TTY prompts. Supports async execution with up to a 2-hour timeout.

---

## Files

```
vsphere_Import_to_VCF9.0.1_Playbook.yml   # Main playbook
var_vault.yml                              # SDDC Manager + vCenter credentials (Vault-encrypted)
vars.yml                                   # Workload domain and NSX parameters
inventory/
└── hosts.ini                              # Inventory (localhost, connection: local)
```

---

## Vault File

`var_vault.yml` — must be encrypted with Ansible Vault before committing:

```bash
ansible-vault encrypt var_vault.yml
```

| Variable | Description |
|----------|-------------|
| `vault_sddc_manager_password` | SDDC Manager SSH password |
| `vault_vcenter_host` | vCenter FQDN or IP to import |
| `vault_vcenter_user` | vCenter SSO username |

---

## vars.yml

```yaml
domain_name:      "vi-workload-domain-01"   # New VI Workload Domain name
datacenter_name:  "HIS-DC"                  # Existing vCenter Datacenter
cluster_name:     "HIS-Clus"                # Existing vCenter Cluster
dvs_name:         "DSwitch-ans"             # Existing Distributed Switch
nsx_vip_fqdn:     "nsx-vip.vsphere.local"   # NSX VIP FQDN
nsx_vip_ip:       "172.23.44.23"
nsx_node1_fqdn:   "ha-nsx-mgr.vsphere.local"
nsx_node1_ip:     "172.23.44.20"
```

---

## Usage

```bash
ansible-playbook vsphere_Import_to_VCF9.0.1_Playbook.yml \
  -i inventory/hosts.ini --ask-vault-pass
```

The vCenter SSO password is prompted interactively at runtime.

---

## Tasks

**Preflight:**
1. Check if `sshpass` is installed on the controller; install if missing
2. Verify the `vcf_brownfield.py` import tool exists on SDDC Manager and display its version

**Import:**

3. SSH into SDDC Manager and execute `vcf_brownfield.py import` with all required flags:
   - `--vcenter` — vCenter FQDN/IP
   - `--sso-user` — SSO username
   - `--domain-name` — VI Workload Domain name
   - `--nsx-fqdn` — NSX VIP FQDN
   - `--accept-trust` — auto-trust certificates and SSH keys
   - `--suppress-warnings` — continue on non-critical warnings
   - `--skip-ssh-thumbprint-validation` — skip SSH host key verification
   - `--skip-nsx-deployment-checks` / `--skip-nsx-overlay-checks`
4. Display full import output
5. Fail with diagnostic message if import exits with non-zero return code

**Result:**

6. Confirm successful import with Workload Domain name, vCenter host, and NSX VIP

---

## Key Notes

- All passwords are passed as environment variables to `vcf_brownfield.py` — no TTY is required.
- `--internal-vcf-auth` flag skips the SDDC Manager local admin password prompt.
- Import tool auto-discovers Datacenter and Cluster from vCenter — no manual mapping needed.
- Import runs asynchronously with a 2-hour (`async: 7200`) timeout and polls every 30 seconds.
- Import logs are written to `/tmp/vcf_import_<domain_name>/` on the SDDC Manager node.

---

## Requirements

- `sshpass` on the Ansible controller node
- Network access from controller to SDDC Manager on port 22 (SSH)
- VCF 9.0.1 SDDC Manager with `vcf_brownfield.py` tool version `9.0.1.0-24962179`
