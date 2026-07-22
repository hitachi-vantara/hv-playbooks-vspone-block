# Hitachi VSP One Block Shared LVM Automation for Proxmox VE

This repository provides host-side automation scripts for configuring Hitachi VSP One Block multipath LUNs as shared LVM storage across a Proxmox VE cluster.

Supported connectivity options:

- Fibre Channel
- iSCSI

Each script validates the configured Proxmox VE nodes, performs protocol-specific storage discovery or rescanning, verifies the intended multipath WWID across the cluster, creates or reuses the LVM physical volume and volume group, activates the volume group on every configured node, and displays a final validation summary.

## Repository contents

```text
proxmox-vspone-block/
├── README.md
├── RELEASE_NOTES.md
├── SHA256SUMS
├── configure-hitachi-fc-lvm.sh
└── configure-hitachi-iscsi-lvm.sh
```

## Operational scope

The scripts perform Proxmox VE host-side operations only. They do not:

- Create Hitachi storage volumes
- Configure Hitachi host groups or iSCSI targets
- Configure Fibre Channel zoning
- Configure Linux multipath policy
- Remove an existing physical volume or volume group
- Erase filesystem or partition signatures
- Register the volume group as a Proxmox VE storage object

Before execution, the Hitachi LUN must be created, mapped to every eligible Proxmox VE node, and presented consistently through Linux multipath.

## Prerequisites

Verify the following requirements before running either script:

- Run the script as `root` from one of the Proxmox VE nodes listed in the script configuration.
- The Proxmox VE cluster is healthy and quorate.
- Passwordless SSH access is configured from the execution node to every other configured node.
- The account specified by `SSH_USER` has direct root privileges on every node.
- `multipath-tools` and LVM2 are installed on every node.
- `multipathd` is running and the required Hitachi multipath policy is already configured.
- The same Hitachi LUN and WWID are visible on every configured node.
- The intended LUN does not contain data that must be retained.
- The proposed volume group name is not already assigned to another device.

Additional iSCSI requirements:

- `open-iscsi` is installed on every node.
- Each node can reach the configured Hitachi iSCSI target portals.
- Any required iSCSI authentication settings are configured before execution.

Additional Fibre Channel requirements:

- Fibre Channel zoning is complete.
- Hitachi host groups and LUN mappings are complete.
- At least one FC HBA port is online on every configured node.

## Configure the scripts

Edit the applicable script before execution. Only values in the `USER CONFIGURATION` section should be changed.

```bash
vi configure-hitachi-iscsi-lvm.sh
```

or:

```bash
vi configure-hitachi-fc-lvm.sh
```

### Proxmox VE nodes

Replace the node placeholders with the actual Proxmox VE node names and management IP addresses or resolvable hostnames.

```bash
NODE_NAMES=(
  "REPLACE_WITH_NODE1_NAME"
  "REPLACE_WITH_NODE2_NAME"
  "REPLACE_WITH_NODE3_NAME"
)

NODE_IPS=(
  "REPLACE_WITH_NODE1_IP"
  "REPLACE_WITH_NODE2_IP"
  "REPLACE_WITH_NODE3_IP"
)
```

Add or remove matching entries based on the cluster size. `NODE_NAMES` and `NODE_IPS` must contain the same number of entries and use the same order.

Example for a four-node cluster:

```bash
NODE_NAMES=(
  "pve-node01"
  "pve-node02"
  "pve-node03"
  "pve-node04"
)

NODE_IPS=(
  "192.0.2.11"
  "192.0.2.12"
  "192.0.2.13"
  "192.0.2.14"
)
```

The script may be executed from any node included in these arrays.

### Hitachi LUN WWID

Identify the intended Hitachi multipath LUN and enter its WWID:

```bash
multipath -ll
```

Update:

```bash
EXPECTED_WWID="REPLACE_WITH_HITACHI_LUN_WWID"
```

The script constructs the stable device path from the WWID:

```text
/dev/disk/by-id/dm-uuid-mpath-<WWID>
```

The multipath map name, such as `mpatha`, can differ between nodes. The script therefore uses the WWID-based path rather than the local map name.

To select a multipath device during execution instead, set:

```bash
EXPECTED_WWID=""
```

The script will display the multipath devices visible on the execution node and prompt for a device number. Review the WWID and capacity carefully before proceeding.

### iSCSI target portals

The iSCSI script requires the Hitachi iSCSI target portal addresses:

```bash
ISCSI_TARGET_PORTALS=(
  "REPLACE_WITH_ISCSI_PORTAL1_IP"
  "REPLACE_WITH_ISCSI_PORTAL2_IP"
)
```

The default iSCSI TCP port is used when no port is specified. A non-default port can be entered as `IP:port` or `hostname:port`.

### Volume group name

The default volume group names are:

```bash
VG_NAME="vg_hitachi_fc"
```

and:

```bash
VG_NAME="vg_hitachi_iscsi"
```

Change `VG_NAME` before execution when a different naming convention is required.

## Verify the downloaded files

From the repository directory, verify the package checksums:

```bash
sha256sum -c SHA256SUMS
```

## Execute the scripts

Clone the repository and change to the repository directory:

```bash
git clone https://github.com/hitachi-vantara/proxmox-vspone-block.git
cd proxmox-vspone-block
```

Run the Fibre Channel script:

```bash
chmod +x configure-hitachi-fc-lvm.sh
./configure-hitachi-fc-lvm.sh
```

Run the iSCSI script:

```bash
chmod +x configure-hitachi-iscsi-lvm.sh
./configure-hitachi-iscsi-lvm.sh
```

The script first displays the configured nodes, protocol-specific values, volume group name, and WWID. Enter `y` only after confirming the displayed configuration.

A second confirmation is displayed immediately before LVM creation or reuse:

```text
Proceed with the above configuration? [y/N]:
```

Only `y` or `yes` continues. Any other response cancels the operation before PV or VG creation.

## Fibre Channel workflow

The Fibre Channel script performs the following operations:

1. Validates node access and required commands on every configured node.
2. Verifies that FC hosts exist and at least one HBA port is online on every node.
3. Rescans SCSI hosts and refreshes multipath on every node.
4. Displays available multipath devices and validates the configured or selected WWID.
5. Verifies that the WWID-based device path is visible on every node.
6. Checks for active mounts, filesystem or partition signatures, existing PV ownership, and VG conflicts.
7. Creates or reuses the LVM physical volume and creates the configured volume group on the execution node.
8. Refreshes LVM metadata and activates the volume group on every configured node.
9. Displays a final per-node FC HBA, WWID, volume group, and PASS/FAIL summary.

## iSCSI workflow

The iSCSI script performs the following operations:

1. Validates node access and required commands on every configured node.
2. Enables `iscsid` and discovers the configured Hitachi iSCSI target portals on every node.
3. Logs in to discovered targets, configures automatic session startup, rescans sessions, and refreshes multipath.
4. Displays available multipath devices and validates the configured or selected WWID.
5. Verifies that the WWID-based device path is visible on every node.
6. Checks for active mounts, filesystem or partition signatures, existing PV ownership, and VG conflicts.
7. Creates or reuses the LVM physical volume and creates the configured volume group on the execution node.
8. Refreshes LVM metadata and activates the volume group on every configured node.
9. Displays a final per-node iSCSI session, WWID, volume group, and PASS/FAIL summary.

## Add the volume group to Proxmox VE

After every configured node reports `PASS`, add the volume group as shared LVM storage through the Proxmox VE web interface or with `pvesm`.

Fibre Channel example:

```bash
pvesm add lvm hitachi-fc-shared \
  --vgname vg_hitachi_fc \
  --content images \
  --shared 1
```

iSCSI example:

```bash
pvesm add lvm hitachi-iscsi-shared \
  --vgname vg_hitachi_iscsi \
  --content images \
  --shared 1
```

Adjust the storage ID, content types, and Proxmox VE storage options to match the deployment requirements.

## Safety behavior

The scripts stop before LVM creation when any of the following conditions are detected:

- Required configuration placeholders remain unchanged.
- The node-name and node-address arrays do not align.
- The execution host is not listed in the configured nodes.
- SSH access or required commands are unavailable on a configured node.
- No online FC HBA port is detected for the FC workflow.
- No active iSCSI session is detected for the iSCSI workflow.
- The configured or selected WWID is missing from any configured node.
- The selected device or a child device is mounted.
- The device belongs to another volume group.
- The proposed volume group already exists on another device.
- Existing filesystem or partition signatures are detected.

The scripts do not run `wipefs`, remove existing LVM objects, or force PV/VG creation.

## Validation recommendation

Validate the scripts in a non-production environment using the same Proxmox VE release, Hitachi VSP One Block presentation model, multipath configuration, and storage protocol intended for production.
