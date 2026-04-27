{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # General Programming
    gcc
    gnumake
    cmake
    pkg-config
    openjdk
    python3
    code-cursor
    # Database & Management Tools
    postgresql
    dbeaver-bin
    mariadb
    # Cybersecurity essentials 
    nmap
    whois
    proxychains
    wireshark
    aircrack-ng
    medusa
    sqlmap
  ];

  # Shared development ergonomics for dev machines.
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql;
    ensureDatabases = [ "isma" "isma_dev" ];
    ensureUsers = [
      {
        name = "isma";
        ensureDBOwnership = true;
      }
    ];
    settings = {
      # Low-resource development settings
      max_connections = 20;
      shared_buffers = "128MB";
    };
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    ensureDatabases = [ "isma_dev" ];
    ensureUsers = [
      {
        name = "isma";
        ensurePermissions = { "isma_dev.*" = "ALL PRIVILEGES"; };
      }
    ];
    settings = {
      mysqld = {
        # Low-resource development settings
        innodb_buffer_pool_size = "128M";
        key_buffer_size = "16M";
      };
    };
  };
}
