{ self, inputs, ... }: {
  flake.nixosModules.laptopConfiguration = { lib, pkgs, userName, hostPrefix, ... }: {
    imports = [
      self.nixosModules.laptopHardware
      self.nixosModules.base
      # Desktop & Apps
      self.nixosModules.noctaliaDesktop
      self.nixosModules.firefox
      self.nixosModules.vscode
      self.nixosModules.alacritty
      # Development
      self.nixosModules.programming
      self.nixosModules.databases
      self.nixosModules.containers
      self.nixosModules.gaming
      # Services
      self.nixosModules.multimedia
      self.nixosModules.productivity
      self.nixosModules.kiwix
      self.nixosModules.llm
      self.nixosModules.nextcloud
      self.nixosModules.pihole
      self.nixosModules.tailscale
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
        # Individual packages
      ];
    };

    filosofo.features = {
      desktop.niri.enable = lib.mkDefault true;
      programming.enable = lib.mkDefault true;
      databases.enable = lib.mkDefault false;  # Laptop is not a dev DB host
      multimedia.enable = lib.mkDefault true;
      productivity.enable = lib.mkDefault true;
      kiwix.enable = lib.mkDefault false;
      llm.enable = lib.mkDefault false;
      nextcloud.enable = lib.mkDefault false;
      pihole.enable = lib.mkDefault false;
      tailscale.enable = lib.mkDefault true;
    };
  };
}
