# Databases — atomic feature for development database services.
# PostgreSQL and MongoDB with pgAdmin/Compass GUI clients.
# Uses lib.mkDefault so nextcloud.nix can merge its own DB ensurements
# without conflicting (nextcloud sets ensureDatabases at mkDefault priority).
{ self, inputs, lib, ... }: {
  flake.nixosModules.databases = { config, pkgs, userName, ... }:
    let
      cfg = config.filosofo.features.databases;
    in
    {
      options.filosofo.features.databases.enable =
        lib.mkEnableOption "Enable development database services (PostgreSQL, MongoDB)";

      config = lib.mkIf cfg.enable {
        # ── PostgreSQL ─────────────────────────────────────────────────────
        services.postgresql = {
          enable = true;
          package = pkgs.postgresql;
          # mkDefault so that nextcloud/other services can add their own DBs
          # without triggering a merge conflict on this list.
          ensureDatabases = lib.mkDefault [ "${userName}" "${userName}_dev" ];
          ensureUsers = lib.mkDefault [
            {
              name = userName;
              ensureDBOwnership = true;
            }
          ];
          settings = {
            max_connections = 50;
            shared_buffers = "256MB";
            # Log slow queries for development
            log_min_duration_statement = 500;
          };
        };

        # ── Home Manager — GUI clients ─────────────────────────────────────
        home-manager.users.${userName} = { pkgs, ... }: {
          home.packages = with pkgs; [
            # PostgreSQL CLI + GUI
            postgresql
            pgadmin4-desktopmode
            # Universal DB client
            dbeaver-bin
          ];
        };
      };
    };
}
