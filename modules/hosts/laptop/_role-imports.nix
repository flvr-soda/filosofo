{ self }:
[
  self.nixosModules.noctaliaDesktop
  self.nixosModules.firefox
  self.nixosModules.vscode
  self.nixosModules.alacritty
  self.nixosModules.programming
  self.nixosModules.databases
  self.nixosModules.containers
  self.nixosModules.gaming
  self.nixosModules.multimedia
  self.nixosModules.productivity
  self.nixosModules.kiwix
  self.nixosModules.llm
  self.nixosModules.nextcloud
  self.nixosModules.pihole
  self.nixosModules.tailscale
]
