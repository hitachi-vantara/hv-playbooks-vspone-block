# InterSystems IRIS Application Consistency Automation With Hitachi Block Storage
Ansible automation to create **application-consistent Thin Image Advanced (TIA) Cascade snapshots** of an **InterSystems IRIS** database running on **Red Hat Enterprise Linux (RHEL)**.
The playbook validates the environment, creates an application-consistent snapshot, mounts the recovery copy on a secondary server, validates database integrity, and cleans up the snapshot environment.
