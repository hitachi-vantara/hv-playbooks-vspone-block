- Ansible control machine must have SSH access to all target servers defined in the inventory file. SSH keys are recommended for password less authentication
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
## Update Ansible module in Ansible Control node to use ansible.posix for mount and unmount.
```````
ansible-galaxy collection install ansible.posix

````````

1.	HTIA snapshots are created by Data protection software (CyberSense) and users want to restore from clean immutable snapshot to its original location through Ansible playbook.
2.	Follow the Readme file to use Ansible.
3.	Run the playbook snapshot_restore.yml 
4.	Prompt will appear to put the user input
5.	User needs to put the primary volume id to get all snapshot pair details. 

6.	User is asked to check the snapshot pairs and get the mirror_unit_id to do point-in-time Snapshot restore. 

7.	Get the details from all snapshots by scrolling up the tab.


 

8.	Again, prompt is appeared to put the required details for restore.
9.	User needs to provide Primary_volume_id and mirror_unit_id to continue the restoration task. 

10.	Restoration is completed and data is recovered to its original location and remount the directory is needed to view the recovered data.

 

11.	Now, another prompt appeared for remount task.
12.	Users need to provide production server IP, mount path and device path.
13.	Unmount task, then filesystem repair task and mount task are performed. 

14.	Data are visible from production host.
 

