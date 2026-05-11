{ self }:
[
  self.nixosModules.arr-stack
  self.nixosModules.databases
  self.nixosModules.multimedia
  self.nixosModules.kiwix
  self.nixosModules.llm
  self.nixosModules.nextcloud
  self.nixosModules.pihole
  self.nixosModules.tailscale
  self.nixosModules.caddy
  self.nixosModules.virtualization
]
