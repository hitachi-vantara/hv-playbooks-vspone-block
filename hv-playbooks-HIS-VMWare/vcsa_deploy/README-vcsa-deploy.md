# vcsa_deploy

Deploys VMware vCenter Server Appliance (VCSA) 9.x to a standalone ESXi host using the official `vcsa-deploy` CLI tool bundled inside the VCSA ISO. After deployment, automatically configures vCenter with a Datacenter, Cluster, Virtual Distributed Switch (VDS), and a VLAN Port Group. Runs as two sequential plays in a single playbook.

---

## Directory Structure

```
vcsa_deploy/
├── vcsa_deploy.yml                       # Entry point (2-stage play)
├── vmware_inventory.yml                  # Localhost inventory
└── roles/
    └── vcf_vmware/
        └── templates/
            └── vcsa_deploy_config.json.j2   # VCSA deployment JSON template
```

---

## Vault File

`ansible_vault_vmware_var.yml` — must be created and encrypted manually:

```bash
ansible-vault create ansible_vault_vmware_var.yml
```

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

---

## Prerequisite — Mount VCSA ISO

```bash
sudo mkdir -p /mnt/vcsa-iso
sudo mount -o loop VMware-VCSA-all-9.0.1.0.24957454.iso /mnt/vcsa-iso
```

---

## Usage

```bash
ansible-playbook -i vmware_inventory.yml vcsa_deploy.yml --ask-vault-pass
```

---

## Tasks

**Stage 1 — VCSA VM Deployment:**
1. Verify VCSA ISO is mounted and `vcsa-deploy` binary exists
2. Render VCSA deployment JSON config from Jinja2 template
3. Run `vcsa-deploy install` (takes 30–60 minutes)
4. Remove temporary config file (contains passwords)
5. Wait for vCenter HTTPS API to become reachable on port 443

**Stage 2 — vCenter Configuration:**
1. Create Datacenter
2. Create Cluster inside the Datacenter
3. Create Virtual Distributed Switch (VDS)
4. Create VLAN Port Group on the VDS

> Stage 2 begins automatically after Stage 1 completes. The Ansible controller must reach the VCSA IP on port 443.

---

## Requirements

```bash
ansible-galaxy collection install community.vmware
```
