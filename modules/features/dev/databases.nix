{ self, inputs, ... }: {
  flake.nixosModules.databases = { pkgs, userName, ... }: {
    # NixOS System-Level Configuration
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql;
      ensureDatabases = [ userName "${userName}_dev" ];
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

    services.mysql = {
      enable = true;
      package = pkgs.mariadb;
      ensureDatabases = [ "${userName}_dev" ];
      ensureUsers = [
        {
          name = userName;
          ensurePermissions = { "${userName}_dev.*" = "ALL PRIVILEGES"; };
        }
      ];
      settings.mysqld = {
        innodb_buffer_pool_size = "128M";
        key_buffer_size = "16M";
      };
    };

    # Home Manager User-Level Configuration
    home-manager.users.${userName} = { pkgs, ... }: {
      home.packages = with pkgs; [
        postgresql
        mariadb
        dbeaver-bin
      ];
    };
  };
}
