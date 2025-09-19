**Prerequisites for Snapshot Restore to the server.**
Ansible control machine must have SSH access to all target servers defined in the inventory file. SSH keys are recommended for passwordless authentication.
## Use the vi editor to add the target servers in the inventory file.
``````
vi /etc/ansible/hosts
[prodhost]
10.25.1.56
10.25.1.57
````````

## Copy the SSH key from the Ansible control machine to the target server.
````````
ssh-copy-id root@targetserver

````````
## Update Ansible module in Ansible Control node to use ansible.posix.mount for mount and ansible.builtin.command for unmount and repair filesystem.
```````
ansible-galaxy collection install ansible.posix

````````
**User guide of snapshot_restore.yml playbook**
1.	HTIA snapshots are created by Data protection software (CyberSense), and users want to restore from a clean, immutable snapshot to its original location through an Ansible playbook.
2.	Follow the Readme file to use Ansible.
3.	Run the playbook snapshot_restore.yml. 
4.	A prompt will appear to accept the user input.
5.	User needs to put the primary volume id to get all snapshot pair details. 
6.	The user is asked to check the snapshot pairs and get the mirror_unit_id to perform a point-in-time Snapshot restore. 
7.	Get the details from all snapshots by scrolling up the tab.
8.	Again, a prompt appears to put in the required details for restoration.
9.	The user needs to provide Primary_volume_id and mirror_unit_id to continue the restoration task. 
10.	Restoration is completed, and data is recovered to its original location. You need to remount the directory to view the recovered data.
11.	Now, another prompt appeared for the remount task.
12.	Users need to provide the production server IP, the mount path, and the device path.
13.	Unmount task, then filesystem repair task and mount task are performed. 
14.	Data are visible from the production host.
 

