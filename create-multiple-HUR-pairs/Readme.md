# Ansible Playbook: Bulk creation of multiple HUR pairs
# Overview
Simplify large-scale Hitachi Universal Replicator (HUR) pair provisioning with Red Hat Ansible automation. In environments where hundreds of HUR pairs need to be created—such as 128 or 256 pairs—provisioning each pair individually using the hv_hur module can be both time-consuming and inefficient. To address this challenge, Hitachi Vantara Automation introduces the "hv_hur_bulk" module, which is specifically designed for high-volume HUR pair creation. This Ansible Playbook enables batch provisioning of multiple HUR pairs based on parameters defined in a user-supplied variable file, including the number of pairs to create, start and end LDEV IDs, capacity saving settings, preconfigured host groups, and journal assignments. During execution, the playbook dynamically applies these inputs to automate the end-to-end provisioning process, significantly reducing deployment time and simplifying large-scale disaster recovery configuration.

# Test Environment
Below diagram depicts a standard UR configuration with 128 HUR pairs and 2x Journal Groups.

![Remote Replication Diagram](./assets/HUR_Replication.png)

# Prerequisite
# Execution
**Sample Output:**
