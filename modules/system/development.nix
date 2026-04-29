{ pkgs, userName, ... }: {
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
      # Low-resource development settings
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
    settings = {
      mysqld = {
        # Low-resource development settings
        innodb_buffer_pool_size = "128M";
        key_buffer_size = "16M";
      };
    };
  };

  # Arduino Support
  users.users.${userName}.extraGroups = [ "dialout" "tty" ];
  services.udev.packages = [ pkgs.arduino-ide ];
}
