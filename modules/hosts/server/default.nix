{ self, inputs, userName, userFullName, userEmail, gitName, stateVersion, timeZone, defaultLocale, extraLocale, keyMap, hostPrefix, ... }: {
  flake.nixosConfigurations.server = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs self userName userFullName userEmail gitName stateVersion timeZone defaultLocale extraLocale keyMap hostPrefix; };
    modules = [
      ./hardware-configuration.nix
      self.nixosModules.base
      self.nixosModules.users
      self.nixosModules.secrets
      self.nixosModules.shared
      self.nixosModules.jellyfin
      self.nixosModules.ai
      self.nixosModules.shell
      ({ pkgs, userName, ... }: {
        networking.hostName = "${hostPrefix}-server";
      })
    ];
  };
}
