{ self, inputs, userName, userFullName, userEmail, gitName, stateVersion, timeZone, defaultLocale, extraLocale, keyMap, hostPrefix, ... }: {
  flake.nixosConfigurations.laptop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs self userName userFullName userEmail gitName stateVersion timeZone defaultLocale extraLocale keyMap hostPrefix; };
    modules = [
      ./hardware-configuration.nix
      self.nixosModules.base
      self.nixosModules.users
      self.nixosModules.graphical
      self.nixosModules.development
      self.nixosModules.gaming
      self.nixosModules.secrets
      self.nixosModules.shared
      self.nixosModules.shell
      ({ pkgs, userName, ... }: {
        networking.hostName = "${hostPrefix}-laptop";

        services.tlp.enable = true;
        services.power-profiles-daemon.enable = false;
        powerManagement.powertop.enable = true;

        environment.systemPackages = with pkgs; [
          brightnessctl
        ];
      })
    ];
  };
}
