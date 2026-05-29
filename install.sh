#!/usr/bin/env bash
# install.sh — Automated Filosofo NixOS Installer
# Disk IDs are hardcoded in each host's _disko.nix file.
# Edit those files before running this script if your hardware differs.

set -e

export NIX_CONFIG="experimental-features = nix-command flakes"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}❌ Please run as root.${NC}"
  exit 1
fi

HOST=$1

if [[ "$HOST" != "desktop-main" && "$HOST" != "laptop-dev" && "$HOST" != "laptop-basic" && "$HOST" != "server-01" && "$HOST" != "server-02" && "$HOST" != "server-03" ]]; then
  echo -e "Usage: ${BOLD}$0 [desktop-main|laptop-dev|laptop-basic|server-01|server-02|server-03]${NC}"
  exit 1
fi

DISKO_FILE="modules/hosts/$HOST/_disko.nix"

echo -e "${BOLD}======================================${NC}"
echo -e "${BOLD}    Filosofo NixOS Installer ($HOST)  ${NC}"
echo -e "${BOLD}======================================${NC}"
echo ""

# Show current hardware
echo -e "${CYAN}--- Your Disks ---${NC}"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT
echo ""
echo -e "${CYAN}--- by-id Links ---${NC}"
ls /dev/disk/by-id/ 2>/dev/null || echo "(none found)"
echo ""

# Show what the disko config expects
echo -e "${CYAN}--- Configured Disk IDs in $DISKO_FILE ---${NC}"
grep 'device' "$DISKO_FILE" | grep -v '#' | sed 's/^[[:space:]]*//'
echo ""

echo -e "${RED}${BOLD}⚠  WARNING: This will WIPE the disks listed above.${NC}"
read -p "Do the configured disk IDs match your hardware? [y/N]: " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Aborted. Edit $DISKO_FILE with the correct disk IDs and try again."
  exit 0
fi

# --- Phase 1: Disko ---
echo ""
echo -e "${GREEN}▶ Starting Disko partitioning...${NC}"
nix run github:nix-community/disko/latest -- --mode disko --flake .#$HOST

# --- Phase 2: Secrets from USB ---
echo ""
echo -e "${GREEN}▶ Partitioning complete. Now preparing secrets...${NC}"
echo -e "${CYAN}--- Available Partitions ---${NC}"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT
echo ""
read -p "Enter your USB partition device containing secrets (e.g. /dev/sdc1): " usb_dev

if [ ! -e "$usb_dev" ]; then
  echo -e "${RED}❌ USB device $usb_dev not found.${NC}"
  exit 1
fi

mkdir -p /mnt/usb
mount "$usb_dev" /mnt/usb

# Service secrets
mkdir -p /mnt/persist/secrets
chmod 0751 /mnt/persist/secrets

for f in nextcloud-admin-password kavita-token searxng open-webui netbird-setup-key; do
  if [ -f "/mnt/usb/$f" ]; then
    cp "/mnt/usb/$f" /mnt/persist/secrets/
    echo "  Copied $f"
  fi
done

chmod 0640 /mnt/persist/secrets/* 2>/dev/null || true
chmod 0600 /mnt/persist/secrets/netbird-setup-key 2>/dev/null || true

# SSH keys
mkdir -p /mnt/persist/home/isma/.ssh
chmod 0700 /mnt/persist/home/isma/.ssh

for key in id_filosofo id_github; do
  if [ -f "/mnt/usb/$key" ]; then
    cp "/mnt/usb/$key" /mnt/persist/home/isma/.ssh/
    echo "  Copied $key"
  fi
done

chmod 0600 /mnt/persist/home/isma/.ssh/id_filosofo 2>/dev/null || true
chmod 0400 /mnt/persist/home/isma/.ssh/id_github 2>/dev/null || true
chown -R 1000:100 /mnt/persist/home/isma/.ssh

# --- Phase 3: Passwords ---
echo ""
echo -e "${GREEN}▶ Setting user and root passwords...${NC}"
read -s -p "Enter new password for user 'isma': " user_pass
echo ""
read -s -p "Enter new password for 'root': " root_pass
echo ""

echo "Hashing passwords..."
user_hash=$(nix run nixpkgs#mkpasswd -- -m bcrypt <<< "$user_pass")
root_hash=$(nix run nixpkgs#mkpasswd -- -m bcrypt <<< "$root_pass")

echo "$user_hash" > /mnt/persist/passwd
echo "$root_hash" > /mnt/persist/root-passwd
chmod 0600 /mnt/persist/passwd
chmod 0600 /mnt/persist/root-passwd

umount /mnt/usb

# --- Phase 4: Install ---
echo ""
echo -e "${GREEN}▶ Starting NixOS Installation...${NC}"
nixos-install --flake .#$HOST --no-root-passwd

echo ""
echo -e "${GREEN}${BOLD}✅ Installation complete! You can now safely remove the USB and reboot.${NC}"
