# Ansible Playbook: Bulk creation of multiple HUR Pairs
# Overview
Simplify Large-Scale Hitachi Universal Replicator (HUR) pairs creation with Ansible automation. When a customer environment have to create a large number of HUR pair (for example 128, 256 number of pairs), it is quite time consuming to loop through each individual volume using "hv_hur" module, to address this pain point, Hitachi Vantara automation has introduced a new module This Ansible Playbook creates multiple remote paths based on user input in a variable file. Users can provide inputs such as local and remote port pairs and remote path groups as variables, which are then dynamically applied during execution
# Test Environment
# Prerequisite
# Execution
**Sample Output:**
