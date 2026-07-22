# Release Notes

## Version 1.0.0 — July 21, 2026

Initial release of the Hitachi VSP One Block shared LVM automation scripts for Proxmox VE.

### Included files

- `configure-hitachi-fc-lvm.sh`
- `configure-hitachi-iscsi-lvm.sh`
- `README.md`
- `SHA256SUMS`

### Capabilities

- Customer-editable Proxmox VE node names and management addresses
- Support for a variable number of Proxmox VE nodes
- Configured WWID validation with optional runtime multipath-device selection
- Stable WWID-based device paths under `/dev/disk/by-id`
- Fibre Channel HBA validation, SCSI host rescan, and multipath refresh
- iSCSI target discovery, login, automatic session startup, session rescan, and multipath refresh
- Multipath WWID validation across every configured node
- Pre-LVM checks for mounts, signatures, PV ownership, and VG conflicts
- LVM physical volume and volume group creation or safe reuse
- Cluster-wide LVM metadata refresh and VG activation
- Final per-node PASS/FAIL validation summary
- SHA-256 checksums for release-file verification

### Operational boundary

The scripts perform Proxmox VE host-side configuration only. Hitachi volume creation, host-group configuration, iSCSI target configuration, Fibre Channel zoning, multipath policy configuration, and Proxmox VE storage registration remain separate administrative tasks.

### Validation guidance

Validate both scripts in a non-production environment before production use. Confirm the intended WWID, LUN capacity, node list, protocol connectivity, and volume group name before approving the final execution prompt.
