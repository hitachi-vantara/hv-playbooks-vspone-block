#!/usr/bin/env bash
set -Eeuo pipefail

# Configure a Hitachi Fibre Channel multipath LUN as shared LVM storage
# across a Proxmox VE cluster.
#
# Run this script as root from one of the configured Proxmox VE nodes.
# Before running, update only the USER CONFIGURATION section below.

# ============================================================================
# USER CONFIGURATION
# ============================================================================

# Add or remove entries to match the Proxmox VE cluster.
# NODE_NAMES and NODE_IPS must contain the same number of entries and use the
# same order.
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

VG_NAME="vg_hitachi_fc"
SSH_USER="root"

# Recommended: enter the WWID of the Hitachi LUN to configure.
# Leave this value empty to select from the multipath devices displayed by
# the script after the FC host scan and multipath refresh.
EXPECTED_WWID="REPLACE_WITH_HITACHI_LUN_WWID"

# ============================================================================
# END USER CONFIGURATION
# ============================================================================

SCRIPT_NAME="$(basename "$0")"
LOCAL_HOSTNAME="$(hostname -s)"
LOCAL_NODE_INDEX=""
PV_PATH=""
MULTIPATH_ENTRIES=()

SSH_OPTIONS=(
  -o ConnectTimeout=10
  -o ServerAliveInterval=15
  -o StrictHostKeyChecking=accept-new
)

trap 'echo; echo "ERROR: ${SCRIPT_NAME} failed at line ${LINENO}." >&2' ERR

print_banner() {
  echo
  echo "================================================================"
  echo "$1"
  echo "================================================================"
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

cancel() {
  echo "Operation cancelled. No storage changes were made."
  exit 0
}

require_root() {
  [[ ${EUID} -eq 0 ]] || fail "Run this script as root."
}

require_local_commands() {
  local command_name
  local required_commands=(
    awk find grep hostname lsblk multipath
    pvs vgs pvcreate vgcreate pvscan vgscan vgchange
    readlink ssh wipefs xargs
  )

  for command_name in "${required_commands[@]}"; do
    command -v "$command_name" >/dev/null 2>&1 || \
      fail "Required command not found: ${command_name}"
  done
}

validate_simple_name() {
  local value="$1"
  local label="$2"

  [[ "$value" =~ ^[A-Za-z0-9._+-]+$ ]] || \
    fail "${label} contains unsupported characters: ${value}"
}

validate_host() {
  local value="$1"
  local label="$2"

  [[ "$value" =~ ^[A-Za-z0-9._:-]+$ ]] || \
    fail "Invalid ${label}: ${value}"
}

validate_wwid() {
  local value="$1"

  [[ "$value" =~ ^[A-Fa-f0-9]+$ ]] || \
    fail "EXPECTED_WWID must contain only hexadecimal characters: ${value}"
}

validate_configuration() {
  local index

  ((${#NODE_NAMES[@]} > 0)) || fail "NODE_NAMES cannot be empty."
  ((${#NODE_NAMES[@]} == ${#NODE_IPS[@]})) || \
    fail "NODE_NAMES and NODE_IPS must contain the same number of entries."

  validate_simple_name "$VG_NAME" "Volume group name"
  validate_simple_name "$SSH_USER" "SSH user"

  for index in "${!NODE_NAMES[@]}"; do
    [[ -n "${NODE_NAMES[$index]}" ]] || \
      fail "Node name at index ${index} is empty."
    [[ -n "${NODE_IPS[$index]}" ]] || \
      fail "Node address at index ${index} is empty."

    validate_simple_name "${NODE_NAMES[$index]}" "Node name"
    validate_host "${NODE_IPS[$index]}" "node address"

    [[ "${NODE_NAMES[$index]}" != *REPLACE_WITH* ]] || \
      fail "Update placeholder node name: ${NODE_NAMES[$index]}"
    [[ "${NODE_IPS[$index]}" != *REPLACE_WITH* ]] || \
      fail "Update placeholder node address: ${NODE_IPS[$index]}"
  done

  if [[ -n "$EXPECTED_WWID" ]]; then
    [[ "$EXPECTED_WWID" != *REPLACE_WITH* ]] || \
      fail "Update EXPECTED_WWID with the Hitachi LUN WWID."
    validate_wwid "$EXPECTED_WWID"
  fi
}

find_local_node() {
  local index
  local local_ips

  local_ips=" $(hostname -I 2>/dev/null || true) "

  for index in "${!NODE_NAMES[@]}"; do
    if [[ "${NODE_NAMES[$index]}" == "$LOCAL_HOSTNAME" ]] || \
       [[ "$local_ips" == *" ${NODE_IPS[$index]} "* ]]; then
      LOCAL_NODE_INDEX="$index"
      return
    fi
  done

  fail "This host (${LOCAL_HOSTNAME}) does not match any configured Proxmox VE node."
}

is_local_node() {
  local index="$1"
  [[ "$index" == "$LOCAL_NODE_INDEX" ]]
}

run_on_node() {
  local index="$1"
  local command_text="$2"

  if is_local_node "$index"; then
    bash -c "$command_text"
  else
    ssh "${SSH_OPTIONS[@]}" \
      "${SSH_USER}@${NODE_IPS[$index]}" \
      "bash -s" <<<"$command_text"
  fi
}

show_configuration() {
  local index
  local response

  print_banner "Hitachi Fibre Channel shared LVM configuration for Proxmox VE"

  echo "Execution node: ${NODE_NAMES[$LOCAL_NODE_INDEX]} (${NODE_IPS[$LOCAL_NODE_INDEX]})"
  echo
  echo "Configured Proxmox VE nodes:"

  for index in "${!NODE_NAMES[@]}"; do
    printf '  %-20s %s\n' "${NODE_NAMES[$index]}" "${NODE_IPS[$index]}"
  done

  echo
  echo "Volume group: ${VG_NAME}"

  if [[ -n "$EXPECTED_WWID" ]]; then
    echo "Configured WWID: ${EXPECTED_WWID}"
  else
    echo "Configured WWID: not set; selection will be requested"
  fi

  echo
  read -r -p "Continue with this configuration? [y/N]: " response

  case "${response,,}" in
    y|yes) ;;
    *) cancel ;;
  esac
}

validate_node_access() {
  local index

  print_banner "Step 1: Validate node access and required commands"

  for index in "${!NODE_NAMES[@]}"; do
    echo "Checking ${NODE_NAMES[$index]} (${NODE_IPS[$index]})"

    run_on_node "$index" \
      "command -v multipath >/dev/null &&
       command -v pvs >/dev/null &&
       command -v vgs >/dev/null &&
       command -v pvscan >/dev/null &&
       command -v vgscan >/dev/null &&
       command -v vgchange >/dev/null"
  done
}

validate_fc_hbas() {
  local index
  local script_text

  print_banner "Step 2: Validate Fibre Channel HBA status"

  script_text=$'set -Eeuo pipefail\n'
  script_text+=$'shopt -s nullglob\n'
  script_text+=$'fc_hosts=(/sys/class/fc_host/host*)\n'
  script_text+=$'((${#fc_hosts[@]} > 0)) || { echo "No Fibre Channel hosts were detected." >&2; exit 1; }\n'
  script_text+=$'online_count=0\n'
  script_text+=$'for fc_host in "${fc_hosts[@]}"; do\n'
  script_text+=$'  state="$(<"${fc_host}/port_state")"\n'
  script_text+=$'  port_name="$(<"${fc_host}/port_name")"\n'
  script_text+=$'  printf "  %-12s WWPN: %-18s State: %s\\n" "$(basename "$fc_host")" "$port_name" "$state"\n'
  script_text+=$'  [[ "$state" == "Online" ]] && online_count=$((online_count + 1))\n'
  script_text+=$'done\n'
  script_text+=$'((online_count > 0)) || { echo "No online Fibre Channel HBA ports were detected." >&2; exit 1; }\n'

  for index in "${!NODE_NAMES[@]}"; do
    echo "Processing ${NODE_NAMES[$index]}"
    run_on_node "$index" "$script_text"
  done
}

rescan_fc_and_refresh_multipath() {
  local index
  local script_text

  print_banner "Step 3: Rescan Fibre Channel storage and refresh multipath"

  script_text=$'set -Eeuo pipefail\n'
  script_text+=$'shopt -s nullglob\n'
  script_text+=$'scan_files=(/sys/class/scsi_host/host*/scan)\n'
  script_text+=$'((${#scan_files[@]} > 0)) || { echo "No SCSI host scan files were detected." >&2; exit 1; }\n'
  script_text+=$'for scan_file in "${scan_files[@]}"; do\n'
  script_text+=$'  echo "- - -" > "$scan_file"\n'
  script_text+=$'done\n'
  script_text+=$'multipath -r >/dev/null\n'

  for index in "${!NODE_NAMES[@]}"; do
    echo "Processing ${NODE_NAMES[$index]}"
    run_on_node "$index" "$script_text"
  done
}

list_multipath_devices() {
  local entries=()
  local entry
  local index
  local device
  local size
  local array_id
  local map_line
  local wwid
  local marker

  mapfile -t entries < <(
    find /dev/disk/by-id -maxdepth 1 -type l \
      -name 'dm-uuid-mpath-*' -printf '%f\n' | sort
  )

  ((${#entries[@]} > 0)) || \
    fail "No multipath devices were found under /dev/disk/by-id."

  print_banner "Step 4: Available multipath devices"

  for index in "${!entries[@]}"; do
    entry="${entries[$index]}"
    wwid="${entry#dm-uuid-mpath-}"
    device="$(readlink -f "/dev/disk/by-id/${entry}")"
    size="$(lsblk -dn -o SIZE "$device" 2>/dev/null | xargs || true)"
    map_line="$(multipath -ll "$wwid" 2>/dev/null | head -n 1 || true)"
    array_id="${map_line##* }"
    marker=""

    if [[ -n "$EXPECTED_WWID" && "$wwid" == "$EXPECTED_WWID" ]]; then
      marker="  <-- configured"
    fi

    printf '  %2d) WWID: %s%s\n' "$((index + 1))" "$wwid" "$marker"
    printf '      Device: %s | Size: %s | Array: %s\n' \
      "$device" "${size:-unknown}" "${array_id:-unknown}"
  done

  MULTIPATH_ENTRIES=("${entries[@]}")
}

select_or_validate_wwid() {
  local selected
  local entry
  local found="false"

  if [[ -n "$EXPECTED_WWID" ]]; then
    for entry in "${MULTIPATH_ENTRIES[@]}"; do
      if [[ "${entry#dm-uuid-mpath-}" == "$EXPECTED_WWID" ]]; then
        found="true"
        break
      fi
    done

    [[ "$found" == "true" ]] || \
      fail "Configured WWID ${EXPECTED_WWID} was not found on ${LOCAL_HOSTNAME}."

    PV_PATH="/dev/disk/by-id/dm-uuid-mpath-${EXPECTED_WWID}"

    echo
    echo "Using configured WWID: ${EXPECTED_WWID}"
    return
  fi

  echo
  read -r -p "Select the multipath device number: " selected

  [[ "$selected" =~ ^[1-9][0-9]*$ ]] || \
    fail "Enter a valid device number."
  ((selected >= 1 && selected <= ${#MULTIPATH_ENTRIES[@]})) || \
    fail "Device selection is out of range."

  entry="${MULTIPATH_ENTRIES[$((selected - 1))]}"
  EXPECTED_WWID="${entry#dm-uuid-mpath-}"
  PV_PATH="/dev/disk/by-id/${entry}"

  echo
  echo "Selected WWID: ${EXPECTED_WWID}"
}

validate_selected_wwid_on_all_nodes() {
  local index
  local quoted_wwid
  local quoted_path

  printf -v quoted_wwid '%q' "$EXPECTED_WWID"
  printf -v quoted_path '%q' "$PV_PATH"

  print_banner "Step 5: Validate the selected WWID on every node"

  for index in "${!NODE_NAMES[@]}"; do
    echo "Validating ${EXPECTED_WWID} on ${NODE_NAMES[$index]}"

    run_on_node "$index" \
      "test -e ${quoted_path} &&
       multipath -ll | grep -Fq -- ${quoted_wwid}"
  done
}

validate_device_safety() {
  local existing_vg
  local signatures
  local mountpoints

  print_banner "Step 6: Validate the selected device before LVM creation"

  mountpoints="$(lsblk -nr -o MOUNTPOINT "$PV_PATH" 2>/dev/null | grep -v '^$' || true)"
  [[ -z "$mountpoints" ]] || \
    fail "The selected device or one of its child devices is mounted."

  existing_vg="$(
    pvs --noheadings -o vg_name "$PV_PATH" 2>/dev/null | xargs || true
  )"

  if [[ -n "$existing_vg" ]]; then
    if [[ "$existing_vg" == "$VG_NAME" ]]; then
      echo "The selected device is already an LVM PV in volume group ${VG_NAME}."
      return
    fi

    fail "The selected device already belongs to volume group '${existing_vg}'."
  fi

  if pvs "$PV_PATH" >/dev/null 2>&1; then
    if vgs "$VG_NAME" >/dev/null 2>&1; then
      fail "The selected PV is unassigned, but volume group '${VG_NAME}' already exists."
    fi

    echo "The selected device is already an unassigned LVM physical volume."
    return
  fi

  if vgs "$VG_NAME" >/dev/null 2>&1; then
    fail "Volume group '${VG_NAME}' already exists on a different device."
  fi

  signatures="$(wipefs -n "$PV_PATH" 2>/dev/null | awk 'NR > 1 {print}' || true)"

  if [[ -n "$signatures" ]]; then
    echo "$signatures"
    fail "Existing filesystem or partition signatures were found. No changes were made."
  fi

  echo "No conflicting LVM ownership, mounts, or filesystem signatures were detected."
}

confirm_changes() {
  local confirmation

  echo
  echo "Planned configuration"
  echo "  Protocol:       Fibre Channel"
  echo "  WWID:           ${EXPECTED_WWID}"
  echo "  Multipath path: ${PV_PATH}"
  echo "  Volume group:   ${VG_NAME}"
  echo "  Nodes:          ${NODE_NAMES[*]}"
  echo

  read -r -p "Proceed with the above configuration? [y/N]: " confirmation

  case "${confirmation,,}" in
    y|yes)
      echo "Proceeding with LVM configuration."
      ;;
    *) cancel ;;
  esac
}

create_or_reuse_lvm() {
  local existing_vg

  print_banner "Step 7: Create or reuse the physical volume and volume group"

  existing_vg="$(
    pvs --noheadings -o vg_name "$PV_PATH" 2>/dev/null | xargs || true
  )"

  if [[ "$existing_vg" == "$VG_NAME" ]]; then
    echo "Volume group ${VG_NAME} already exists on the selected device."
    return
  fi

  if ! pvs "$PV_PATH" >/dev/null 2>&1; then
    pvcreate "$PV_PATH"
  else
    echo "Reusing the existing unassigned LVM physical volume."
  fi

  if ! vgs "$VG_NAME" >/dev/null 2>&1; then
    vgcreate "$VG_NAME" "$PV_PATH"
  fi
}

activate_vg_on_all_nodes() {
  local index
  local quoted_vg

  printf -v quoted_vg '%q' "$VG_NAME"

  print_banner "Step 8: Refresh LVM metadata and activate the volume group"

  for index in "${!NODE_NAMES[@]}"; do
    echo "Activating ${VG_NAME} on ${NODE_NAMES[$index]}"

    run_on_node "$index" \
      "pvscan --cache >/dev/null
       vgscan --mknodes >/dev/null
       vgchange -ay ${quoted_vg} >/dev/null"
  done
}

print_validation_summary() {
  local index
  local hba_status
  local wwid_status
  local vg_status
  local final_status
  local overall_status=0
  local quoted_wwid
  local quoted_vg
  local quoted_path

  printf -v quoted_wwid '%q' "$EXPECTED_WWID"
  printf -v quoted_vg '%q' "$VG_NAME"
  printf -v quoted_path '%q' "$PV_PATH"

  print_banner "Final validation summary"

  printf '%-20s %-12s %-10s %-20s %-8s\n' \
    "Node" "FC HBA" "WWID" "Volume group" "Status"
  printf '%-20s %-12s %-10s %-20s %-8s\n' \
    "--------------------" "------------" "----------" \
    "--------------------" "--------"

  for index in "${!NODE_NAMES[@]}"; do
    if run_on_node "$index" \
      "shopt -s nullglob
       fc_hosts=(/sys/class/fc_host/host*)
       ((\${#fc_hosts[@]} > 0)) || exit 1
       grep -q '^Online$' /sys/class/fc_host/host*/port_state"; then
      hba_status="Online"
    else
      hba_status="Check"
    fi

    if run_on_node "$index" \
      "test -e ${quoted_path} &&
       multipath -ll | grep -Fq -- ${quoted_wwid}"; then
      wwid_status="Visible"
    else
      wwid_status="Missing"
    fi

    if run_on_node "$index" "vgs ${quoted_vg} >/dev/null 2>&1"; then
      vg_status="$VG_NAME"
    else
      vg_status="Not found"
    fi

    if [[ "$hba_status" == "Online" &&
          "$wwid_status" == "Visible" &&
          "$vg_status" == "$VG_NAME" ]]; then
      final_status="PASS"
    else
      final_status="FAIL"
      overall_status=1
    fi

    printf '%-20s %-12s %-10s %-20s %-8s\n' \
      "${NODE_NAMES[$index]}" "$hba_status" "$wwid_status" \
      "$vg_status" "$final_status"
  done

  ((overall_status == 0)) || fail "One or more nodes failed final validation."

  echo
  echo "Completed: Fibre Channel HBA validation, FC storage rescan,"
  echo "multipath validation, PV/VG configuration, and shared"
  echo "volume-group validation."
  echo
  echo "Next step: Add '${VG_NAME}' as shared LVM storage in Proxmox VE."
  echo "Example: pvesm add lvm <storage-id> --vgname '${VG_NAME}' --content images --shared 1"
}

main() {
  require_root
  require_local_commands
  validate_configuration
  find_local_node
  show_configuration
  validate_node_access
  validate_fc_hbas
  rescan_fc_and_refresh_multipath
  list_multipath_devices
  select_or_validate_wwid
  validate_selected_wwid_on_all_nodes
  validate_device_safety
  confirm_changes
  create_or_reuse_lvm
  activate_vg_on_all_nodes
  print_validation_summary
}

main "$@"
