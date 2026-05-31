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

# --- Phase 4: Install ---
echo ""
echo -e "${GREEN}▶ Starting NixOS Installation...${NC}"
nixos-install --flake .#$HOST --no-root-passwd

echo ""
echo -e "${GREEN}${BOLD}✅ Installation complete!${NC}"
echo ""
echo -e "${CYAN}--- Next Steps ---${NC}"
echo -e "1. Reboot the system and unplug the USB."
echo -e "2. ${BOLD}Personal SSH Keys:${NC} Since we skipped the USB, securely copy your private keys over from another machine:"
echo -e "   ${BOLD}scp ~/.ssh/id_filosofo ~/.ssh/id_github isma@<new-ip>:~/.ssh/${NC}"
echo -e "3. ${BOLD}SOPS-NIX Secrets:${NC} To decrypt secrets, you need to add this new machine's Age key to .sops.yaml."
echo -e "   Run this on your main machine after the new host is up:"
echo -e "   ${BOLD}ssh-keyscan <ip-address> | ssh-to-age${NC}"
echo -e "   Then add it to .sops.yaml and run: ${BOLD}sops updatekeys secrets/secrets.yaml${NC}"
echo -e "4. ${BOLD}Nextcloud Setup:${NC} Set the admin password manually via occ:"
echo -e "   ${BOLD}sudo nextcloud-occ user:resetpassword admin${NC}"
echo ""
