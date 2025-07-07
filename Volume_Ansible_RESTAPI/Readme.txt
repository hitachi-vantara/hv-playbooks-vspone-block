# Ansible Playbook: Auto-Expand High-Utilization LDEVs

## Overview

This Ansible playbook is designed to monitor LDEVs (Logical Devices) on a Hitachi VSP subsystem, identify those that exceed **80% utilization**, automatically expand their volume by **10%**, and notify the storage administrator via email.

It is intended to be scheduled as a **cron job**, providing automated storage management and proactive capacity handling based on real-time usage.

---

## 🔧 Use Case

- **Environment**: Enterprise storage (e.g., Hitachi VSP Block 20) with Ansible automation
- **Goal**: Automatically expand LDEVs that are nearing full capacity
- **Trigger**: Run periodically (e.g., via `cron`)
- **Action Flow**:
  1. Fetch LDEV details into `ldev_facts_results`
  2. Filter LDEVs with usage > 80%
  3. Expand their size by 10%
  4. Send an email to the storage admin with the following details:
     - LDEV ID
     - Used Space
     - Current Size
     - New Size

---

## Running the Playbook

ansible-playbook playbook.yml

To run as a cron job, add the following to your crontab:

0 */6 * * * /usr/bin/ansible-playbook /path/to/playbook.yml ( Example)


