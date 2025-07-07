# Jira Storage Poller & LDEV Provisioning Automation

This project automates the provisioning of LUNs (Logical Unit Numbers) by integrating Jira issue tracking with Ansible and Hitachi storage modules. It continuously polls Jira for new LUN requests, parses the required size, triggers an Ansible playbook to create the LDEV, and updates the Jira issue with the result.

---

## Components

### 1. `poller.py`
A Python script that:
- Polls Jira for issues labeled `LUN-Request` in the `To Do` status
- Parses the requested LUN size from the issue description
- Triggers an Ansible playbook with the Jira ticket ID and size
- Posts a comment and adds a `lun_processed` label to the Jira issue

### 2. `im_ldev_jira.yml`
An Ansible playbook that:
- Connects to a Hitachi storage subsystem
- Selects the storage pool with the most free space
- Creates a new LDEV using the Jira ticket ID as the volume name
- Uses Ansible Vault to securely load storage credentials


Configure Environment Variables
Create a .env file based on the provided .env.example:

### env
JIRA_URL=https://your-jira-instance.atlassian.net
JIRA_USER=your.email@example.com
JIRA_TOKEN=your_jira_api_token

### Configure Ansible Vault
Encrypt your storage credentials:

bash
ansible-vault create ansible/ansible_vault_vars/ansible_vault_storage_var.yml

Jira Issue Format
Project: IPSESE

Status: To Do

Label: LUN-Request

Description: Must include a line like size: 100 or size=100 (in GB)

Example:

Requesting a new LUN for backup storage.
size: 200

### Ansible Playbook Details
File: ansible/im_ldev_jira.yml

Key Tasks:

Fetch available storage pools

Select the pool with the most free space

Create an LDEV with the specified size

Use Jira ticket ID as the LUN name

Run manually (for testing):

bash
ansible-playbook ansible/im_ldev_jira.yml -e "ticket=ADMIN-123 size=100"

### Logging
Logs are written to:

/opt/jira-storage-poller/logs/poller.log
Each run logs:

Jira polling activity

Issues found and processed

Ansible playbook execution results

Errors and warnings