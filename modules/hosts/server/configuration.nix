{ self, inputs, ... }: {
  flake.nixosModules.serverConfiguration = { userName, hostPrefix, ... }: {
    imports = [
      self.nixosModules.serverHardware
      # Core
      self.nixosModules.system
      self.nixosModules.boot
      self.nixosModules.nixConfig
      self.nixosModules.networking
      self.nixosModules.security
      self.nixosModules.locale
      self.nixosModules.ssh
      self.nixosModules.users
      self.nixosModules.secrets
      self.nixosModules.shared
      # Services
      self.nixosModules.jellyfin
      self.nixosModules.media
      self.nixosModules.nas
      self.nixosModules.kiwix
      self.nixosModules.ai
      self.nixosModules.shell
    ];

    networking.hostName = "${hostPrefix}-server";
  };
}
