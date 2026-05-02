# Flake-parts module exporting development tools and databases.
# This module provides a complete development environment including PostgreSQL, MariaDB, Docker, and programming languages.
{ self, inputs, ... }: {
  flake.nixosModules.development = {
    pkgs,
    userName,
    ...
  }: {
  # NixOS System-Level Configuration
  
  # Configure PostgreSQL with a dedicated development database for the user
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql;
    ensureDatabases = [userName "${userName}_dev"];
    ensureUsers = [
      {
        name = userName;
        ensureDBOwnership = true;
      }
    ];
    settings = {
      max_connections = 20;
      shared_buffers = "128MB";
    };
  };

  # Configure MariaDB (MySQL) with a dedicated development database
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    ensureDatabases = ["${userName}_dev"];
    ensureUsers = [
      {
        name = userName;
        ensurePermissions = {"${userName}_dev.*" = "ALL PRIVILEGES";};
      }
    ];
    settings.mysqld = {
      innodb_buffer_pool_size = "128M";
      key_buffer_size = "16M";
    };
  };

  # Enable Docker for containerised development
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true; # Automatically remove unused images/containers
  };

  # Grant the user access to serial ports for hardware development (e.g. Arduino)
  # and the Docker socket for rootless container management and arduino.
  users.users.${userName}.extraGroups = [ "dialout" "tty" "docker" ];
  services.udev.packages = [ pkgs.arduino-ide ];

  # Home Manager User-Level Configuration
  home-manager.users.${userName} = {pkgs, ...}: {
    home.packages = with pkgs; [
      docker-compose
      gcc
      gnumake
      cmake
      pkg-config
      openjdk
      python3
      nixfmt
      code-cursor
      postgresql
      dbeaver-bin
      mariadb
      arduino-ide
      arduino-cli
      nmap
      whois
      proxychains
      wireshark
      aircrack-ng
      medusa
      sqlmap
    ];

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
};
}
