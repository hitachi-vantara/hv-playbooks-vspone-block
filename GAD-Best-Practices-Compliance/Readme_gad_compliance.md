# Playbooks for GAD Compliance Report with Configurable Thresholds

## Overview

These Ansible playbooks were customized to align with the environment’s specific requirements. 
These modified playbooks were then executed to automate the configuration of GAD Compliance Report with Configurable Thresholds, ensuring consistent, efficient, and error-free checking of active-active volume replication GAD environment across the connected storage systems.

The configuration was completed by executing the following tasks, with playbooks mentioned below:

**Retrieve GAD Pairs:**
Get all GAD pair facts using the hv gad facts module.

**Retrieve Parity Group Facts:**
Get all parity group facts using the hv parity group facts module.


**Retrieve Primary LDEV Facts**
Get all primary ldev facts using the hv ldev facts module

**Retrieve Secondary LDEV Facts:**
Get all secondary ldev facts using the hv ldev facts module


**Build Consolidated Pre-Config Report:**
A report of your GAD configuration is created that uses thresholds such as copy rate track size, copy rate, primary ldev id,and secondary ldev id. Then, details on the ldevs useed in GAD also have checks such as ldev status, capacity, compression status, dedup compression mode, path count and provision type.

## Run and Troubleshoot ansible playbooks

###Execute a playbook task using this command syntax:
>ansible-playbook &lt;name of the yml file&gt;

###To get detailed output, run the playbook with verbose mode using the following syntax:
>ansible-playbook &lt;name of the yml file&gt; -vvv

###To troubleshoot issues, refer to the log file located at:
>$HOME/logs/hitachivantara/ansible/vspone_block/hv_vspone_block_modules.log
