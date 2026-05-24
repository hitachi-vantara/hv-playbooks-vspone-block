# brocade-zoning

Automates Fibre Channel zoning on Brocade G720 switches using the `brocade.fos` Ansible collection. Creates a server alias mapped to its WWPN, builds a zone containing both server and storage aliases, adds the zone to an existing configuration, and activates it — all in a single role-based playbook run.

---

## Directory Structure

```
brocade-zoning/
├── playbook.yml                          # Entry point
├── inventory/
│   └── hosts.yml                         # Switch host + zoning parameters
└── roles/
    └── brocade_zoning/
        └── tasks/
            └── main.yml                  # Alias, zone, cfg tasks
```

---

## Inventory

`inventory/hosts.yml` — define all zoning parameters per switch host:

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

### Inventory Parameters

| Parameter | Description |
|-----------|-------------|
| `ansible_host` | Switch management IP address |
| `fid` | Virtual Fabric ID (VFID) |
| `server_alias` | Alias name for the server host port |
| `server_wwpn` | Server WWPN mapped to the alias |
| `storage_alias` | Existing storage alias on the switch |
| `zone_name` | Name for the new FC zone |
| `cfg_name` | Existing zone configuration to update |
| `log_file` | Log output path |

---

## Usage

```bash
ansible-playbook playbook.yml -i inventory/hosts.yml
```

Switch credentials (`switch_user`, `switch_password`) are prompted interactively at runtime — never stored in any file.

---

## Tasks

1. Create server alias mapped to its WWPN
2. Create zone containing server and storage aliases
3. Add zone to existing configuration and activate it

---

## Requirements

```bash
ansible-galaxy collection install brocade.fos
```
