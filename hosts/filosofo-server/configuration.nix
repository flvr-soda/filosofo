{
  pkgs,
  inputs,
  lib,
  isServer,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../commonSystem.nix
  ];

  # Multimedia server and homelab-specific settings
  services = {
    # Multimedia streaming with Jellyfin
    jellyfin = {
      enable = true;
      openFirewall = true; # Allow access through the firewall
      mediaDirs = [
        "/mnt/media/movies"
        "/mnt/media/music"
        "/mnt/media/tv-shows"
      ];
    };

    # File sharing with Samba
    samba = {
      enable = true;
      extraConfig = ''
        [global]
        workgroup = WORKGROUP
        server string = Filosofo Server
        log file = /var/log/samba/log.%m
        max log size = 50
        security = user
        map to guest = Bad User
        dns proxy = no

        [media]
        path = /mnt/media
        writable = yes
        guest ok = yes
        create mask = 0644
        directory mask = 0755
      '';
    };

    # Enable Docker for containerized services
    docker.enable = true;

    # Enable Prometheus and Grafana for monitoring
    prometheus-node-exporter.enable = true;
    grafana.enable = true;

    # Networking settings for homelab
    tailscale = {
      enable = true;
      acceptRoutes = true; # Accept subnet routes
    };
  };

  # Security settings
  security.sudo.extraRules = [
    {
      users = ["admin"];
      commands = ["ALL"];
    }
  ];

  # Admin user setup
  users.users.admin = {
    isNormalUser = true;
    extraGroups = ["wheel" "docker"];
  };
}
