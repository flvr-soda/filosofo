{ self, inputs, ... }: {
  flake.nixosModules.laptopConfiguration = { pkgs, userName, hostPrefix, ... }: {
    imports = [
      self.nixosModules.laptopHardware
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
      # Desktop & Apps
      self.nixosModules.plasma
      self.nixosModules.firefox
      self.nixosModules.vscode
      self.nixosModules.alacritty
      # Development
      self.nixosModules.programming
      self.nixosModules.containers
      self.nixosModules.gaming
      # Services
      self.nixosModules.shell
    ];

    networking.hostName = "${hostPrefix}-laptop";

    services.tlp.enable = true;
    services.power-profiles-daemon.enable = false;
    powerManagement.powertop.enable = true;

    environment.systemPackages = with pkgs; [
      brightnessctl
    ];

    home-manager.users.${userName} = { pkgs, ... }: {
      home.packages = with pkgs; [
        onlyoffice-desktopeditors
      ];
    };
  };
}
