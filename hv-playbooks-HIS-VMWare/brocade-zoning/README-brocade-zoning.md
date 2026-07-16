# vSphere_Import_to_VCF_playbook — Brocade G720 FC Zoning

Ansible playbook to automate Fibre Channel zoning on Brocade G720 switches using the `brocade.fos` collection. Creates a server alias, builds a zone, adds it to an existing zone configuration, and activates it.

---

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Directory Structure](#directory-structure)
- [Inventory Setup](#inventory-setup)
- [Usage](#usage)
- [Workflow](#workflow)
- [Variables Reference](#variables-reference)
- [Security](#security)

---

## Overview

This playbook performs three zoning operations on a Brocade G720 switch in sequence:

| Step | Task | Module |
|------|------|--------|
| 1 | Create server alias mapped to its WWPN | `brocade.fos.brocade_zoning_alias` |
| 2 | Create zone containing server and storage aliases | `brocade.fos.brocade_zoning_zone` |
| 3 | Add zone to existing configuration and activate | `brocade.fos.brocade_zoning_cfg` |

---

## Prerequisites

### Controller Node

- Ansible ≥ 2.14
- `brocade.fos` collection installed:
  ```bash
  ansible-galaxy collection install brocade.fos
  ```
  Or via the shared `requirements.yml` at the repo root:
  ```bash
  ansible-galaxy collection install -r requirements.yml
  ```

### Network Access

The Ansible controller must be able to reach the Brocade G720 switch management IP on **port 443 (HTTPS)**.

---

## Directory Structure

```
vSphere_Import_to_VCF_playbook.yml.yml   # Main playbook
inventory/
└── hosts.yml                            # Switch host and zoning parameters
```

> Create the `inventory/` directory and `hosts.yml` manually — see [Inventory Setup](#inventory-setup) below.

---

## Inventory Setup

Create `inventory/hosts.yml` with the switch host and all zoning parameters:

```yaml
all:
  children:
    brocade_switches:
      hosts:
        switch01:
          ansible_host: 172.23.55.27        # Switch management IP
          fid: 128                           # Virtual Fabric ID (VFID)
          server_alias: "J02-U5-6-HA820G3-ANS"
          server_wwpn: "10:00:94:40:c9:d0:95:30"
          storage_alias: "B85-70-26-3A"
          zone_name: "J02-U5-6-HA820G3-ANS-B85-70-26-3A"
          cfg_name: "cfg20260218-RM"
          log_file: "/var/log/brocade_zoning.log"
```

---

## Usage

```bash
ansible-playbook vSphere_Import_to_VCF_playbook.yml.yml \
  -i inventory/hosts.yml --ask-vault-pass
```

At runtime you will be prompted for:

| Prompt | Description |
|--------|-------------|
| `switch_user` | Brocade switch login username |
| `switch_password` | Brocade switch login password (hidden) |

Credentials are never stored in any file — they are collected interactively at runtime only.

---

## Workflow

```
[Runtime Prompt]
  switch_user / switch_password
        │
        ▼
┌─────────────────────────────────────┐
│ TASK 1: Create server alias         │
│  server_alias → server_wwpn         │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ TASK 2: Create zone                 │
│  zone_name ← [server_alias,         │
│               storage_alias]        │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ TASK 3: Add zone to cfg & activate  │
│  cfg_name ← zone_name               │
│  active_cfg: cfg_name               │
└─────────────────────────────────────┘
```

Each task prints a debug message showing what changed on the switch.

---

## Variables Reference

All variables are defined per host in `inventory/hosts.yml`. None are hardcoded in the playbook.

| Variable | Description | Example |
|----------|-------------|---------|
| `ansible_host` | Switch management IP address | `172.23.55.27` |
| `fid` | Virtual Fabric ID (VFID) | `128` |
| `server_alias` | Alias name for the server host port | `J02-U5-6-HA820G3-ANS` |
| `server_wwpn` | Server WWPN to map to the alias | `10:00:94:40:c9:d0:95:30` |
| `storage_alias` | Existing storage alias already on the switch | `B85-70-26-3A` |
| `zone_name` | Name for the new FC zone | `J02-U5-6-HA820G3-ANS-B85-70-26-3A` |
| `cfg_name` | Existing zone configuration to add the zone into | `cfg20260218-RM` |
| `log_file` | Path for operation log output | `/var/log/brocade_zoning.log` |
| `switch_user` | Switch username *(prompted at runtime)* | — |
| `switch_password` | Switch password *(prompted at runtime)* | — |

---

## Security

- Switch credentials (`switch_user`, `switch_password`) are **never stored on disk**. They are collected via `vars_prompt` at runtime on every execution.
- The `inventory/hosts.yml` file contains no sensitive data and is safe to commit to version control.
- All switch API calls use HTTPS (`https: self`) with self-signed certificate support.
