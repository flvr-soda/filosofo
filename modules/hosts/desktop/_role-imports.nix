# Shared import list for filosofo-desktop (role). Kept as a plain list so hosts stay thin.
# Homelab-style modules (arr-stack, caddy, …) are listed here explicitly too: there is no
# separate server machine in this fleet yet, so the desktop carries that stack.
{ self }:
[
  self.nixosModules.noctaliaDesktop
  self.nixosModules.firefox
  self.nixosModules.vscode
  self.nixosModules.alacritty
  self.nixosModules.dolphin
  self.nixosModules.printers-gui
  self.nixosModules.programming
  self.nixosModules.databases
  self.nixosModules.containers
  self.nixosModules.cybersec
  self.nixosModules.arr-stack
  self.nixosModules.multimedia
  self.nixosModules.productivity
  self.nixosModules.gaming
  self.nixosModules.virtualization
  self.nixosModules.kiwix
  self.nixosModules.llm
  self.nixosModules.nextcloud
  self.nixosModules.pihole
  self.nixosModules.tailscale
  self.nixosModules.caddy
  self.nixosModules.jellyfin
  self.nixosModules.navidrome
  self.nixosModules.kavita
]
