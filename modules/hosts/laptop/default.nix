{ self, inputs, userName, userFullName, userEmail, gitName, stateVersion, ... }: {
  flake.nixosConfigurations.laptop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs self userName userFullName userEmail gitName stateVersion; };
    modules = [
      ./hardware-configuration.nix
      self.nixosModules.base
      self.nixosModules.users
      self.nixosModules.graphical
      self.nixosModules.development
      self.nixosModules.gaming
      self.nixosModules.secrets
      self.nixosModules.shared
      ({ pkgs, userName, ... }: {
        networking.hostName = "filosofo-laptop";

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
