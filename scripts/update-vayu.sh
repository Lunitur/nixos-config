#!/usr/bin/env bash
set -euo pipefail

flake=${FLAKE:-$HOME/nixos}
ssh_host=${SSH_HOST:-root@vayu.netbird.selfhosted}
system_path=
reboot=false
bootloader=true
use_local=true

usage() {
  cat <<'EOF'
Usage: update-vayu [options]
  --flake PATH       Configuration flake (default: $FLAKE or ~/nixos)
  --system PATH      Deploy an existing system closure instead of building
  --host USER@HOST   SSH target (default: $SSH_HOST or root@vayu.netbird.selfhosted)
  --reboot           Reboot after successful activation and boot-file checks
  --no-bootloader    Activate temporarily; leave the boot generation unchanged
  --no-local         Use the SSH target without trying its LAN address
  -h, --help         Show this help

Non-root targets require passwordless sudo. Builds need an aarch64 builder
or binfmt emulation for userspace packages missing from the binary cache.
EOF
}

die() { echo "Error: $*" >&2; exit 1; }

while (($#)); do
  case "$1" in
    --flake|--system|--host)
      (($# >= 2)) && [[ -n $2 && $2 != -* ]] || die "$1 requires a value"
      case "$1" in
        --flake) flake=$2 ;;
        --system) system_path=$2 ;;
        --host) ssh_host=$2 ;;
      esac
      shift 2 ;;
    --reboot) reboot=true; shift ;;
    --no-bootloader) bootloader=false; shift ;;
    --no-local) use_local=false; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "Unknown option: $1 (see --help)" ;;
  esac
done

case "$flake" in
  \~/*) flake="$HOME/${flake:2}" ;;
esac
[[ $ssh_host != -* && $ssh_host != *[[:space:]]* ]] || die "Invalid SSH target"
$reboot && ! $bootloader && die "--reboot cannot be combined with --no-bootloader"

remote() {
  local command
  printf -v command '%q ' "$@"
  ssh -o ConnectTimeout=5 -o ServerAliveInterval=5 -o ServerAliveCountMax=3 "$ssh_host" "$command"
}

remote true || die "Cannot reach $ssh_host via SSH"
if $use_local; then
  machine_id=$(remote cat /etc/machine-id)
  lan_ip=$(remote ip -o -4 addr show scope global |
    awk '$2 !~ /^(tailscale|wt|nb-|usb)/ { sub(/\/.*/, "", $4); print $4; exit }')
  if [[ -n $lan_ip ]]; then
    ssh_user=$(ssh -G "$ssh_host" | awk '$1 == "user" { print $2; exit }')
    original_host=$ssh_host
    ssh_host="$ssh_user@$lan_ip"
    # Only use the discovered address if SSH reaches the same phone.
    if [[ $(remote cat /etc/machine-id 2>/dev/null || true) != "$machine_id" ]]; then
      ssh_host=$original_host
    fi
  fi
fi
echo "Updating $ssh_host"

privilege=()
if [[ $(remote id -u) != 0 ]]; then
  privilege=(sudo -n)
fi
remote "${privilege[@]}" true || die "The target requires root or passwordless sudo"

work_dir=$(mktemp -d -t update-vayu.XXXXXXXX)
trap 'rm -rf "$work_dir"' EXIT
if [[ -z $system_path ]]; then
  system_path=$(nix build "${flake%#}#nixosConfigurations.vayu.config.system.build.toplevel" \
    --out-link "$work_dir/system" --print-out-paths -L)
else
  system_path=$(readlink -e "$system_path")
  nix-store --add-root "$work_dir/system" --indirect --realise "$system_path" >/dev/null
fi
[[ $system_path =~ ^/nix/store/[a-z0-9]{32}-[^/]+$ && -x $system_path/bin/switch-to-configuration ]] ||
  die "Not a NixOS system closure: $system_path"

boot_files=()
if $bootloader; then
  jq -e '
    .["org.nixos.bootspec.v1"] as $boot |
    [$boot.kernel, $boot.initrd, .["org.nixos.systemd-boot"].devicetree] |
    all(.[]; type == "string" and startswith("/nix/store/"))
  ' "$system_path/boot.json" >/dev/null || die "Missing kernel, initrd, or device tree in boot.json"
  mapfile -t boot_files < <(jq -r '
    .["org.nixos.bootspec.v1"] as $boot |
    $boot.kernel, $boot.initrd, .["org.nixos.systemd-boot"].devicetree
  ' "$system_path/boot.json")
fi

echo "Copying $system_path"
nix copy --to "ssh://$ssh_host" "$system_path"

esp_boot_files() {
  remote "${privilege[@]}" bash -s -- "$1" "$system_path" "${boot_files[@]}" <<'REMOTE'
set -euo pipefail
mode=$1
system_path=$2
shift 2
mountpoint -q /boot || { echo '/boot is not mounted' >&2; exit 1; }

esp_path() {
  local resolved store_dir base
  resolved=$(readlink -f "$1")
  store_dir=${resolved#/nix/store/}
  base=${resolved##*/}
  store_dir=${store_dir%%/*}
  if [[ $base == "$store_dir" ]]; then
    echo "/boot/EFI/nixos/$base.efi"
  else
    echo "/boot/EFI/nixos/$store_dir-$base.efi"
  fi
}

if [[ $mode == install ]]; then
  # Check every store path before removing stale ESP copies.
  for file in "$@"; do
    store_dir=${file#/nix/store/}
    nix-store --verify-path "/nix/store/${store_dir%%/*}"
  done
  for file in "$@"; do
    esp=$(esp_path "$file")
    if [[ -e $esp ]] && ! cmp -s "$file" "$esp"; then
      rm -- "$esp"
    fi
  done

  nix-env -p /nix/var/nix/profiles/system --set "$system_path"
  "$system_path/bin/switch-to-configuration" boot
fi
for file in "$@"; do
  esp=$(esp_path "$file")
  cmp -s "$file" "$esp" || { echo "ESP file missing or corrupt: $esp" >&2; exit 1; }
done
sync
REMOTE
}

if $bootloader; then
  echo "Installing and verifying boot files"
  esp_boot_files install
fi

action=switch
$bootloader || action='test'
unit="vayu-update-$(date +%s)-$$"
echo "Activating $system_path ($action)"
# Let systemd own activation so restarting SSH or networking cannot kill it.
remote "${privilege[@]}" systemd-run --no-block --unit="$unit" \
  --property=Type=oneshot --property=RemainAfterExit=yes \
  "$system_path/bin/switch-to-configuration" "$action" ||
  echo "SSH disconnected; checking activation status after reconnecting"

activated=false
for ((attempt = 0; attempt < 60; attempt++)); do
  state=$(remote "${privilege[@]}" systemctl is-active "$unit" 2>/dev/null || true)
  case "$state" in
    active) activated=true; break ;;
    failed)
      remote "${privilege[@]}" journalctl -u "$unit" -n 30 --no-pager >&2 || true
      die "Activation failed; inspect $unit on the phone" ;;
  esac
  sleep 2
done
$activated || die "Could not confirm activation; inspect $unit on the phone before rebooting"
remote "${privilege[@]}" systemctl stop "$unit"

if $bootloader; then
  esp_boot_files verify
fi
if $reboot; then
  remote "${privilege[@]}" systemctl reboot
fi
echo "Updated $ssh_host to $system_path"
