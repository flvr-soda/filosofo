# databases.nix — Centralised PostgreSQL instance

{ self, inputs, lib, ... }: {
  flake.nixosModules.databases = { config, pkgs, userName, ... }:
    let
      cfg = config.filosofo.features.databases;
    in
    {
      options.filosofo.features.databases.enable =
        lib.mkEnableOption "Enable development database services (PostgreSQL + GUI clients)";

      config = lib.mkIf cfg.enable {
        # ── PostgreSQL ─────────────────────────────────────────────────────
        services.postgresql = {
          enable  = true;
          package = pkgs.postgresql_16;

          ensureDatabases = lib.mkDefault (
            [ "${userName}" "${userName}_dev" ]
            ++ lib.optional config.filosofo.features.nextcloud.enable "nextcloud"
            ++ lib.optional config.filosofo.services.ai.local-inference "open-webui"
          );
          ensureUsers     = lib.mkDefault (
            [
              {
                name              = userName;
                ensureDBOwnership = true;
              }
            ]
            ++ lib.optionals config.filosofo.features.nextcloud.enable [
              {
                name              = "nextcloud";
                ensureDBOwnership = true;
              }
            ]
            ++ lib.optionals config.filosofo.services.ai.local-inference [
              {
                name              = "open-webui";
                ensureDBOwnership = true;
              }
            ]
          );

          settings = {
            max_connections       = 100;
            shared_buffers        = "512MB";
            effective_cache_size  = "1536MB";
            maintenance_work_mem  = "128MB";
            log_min_duration_statement = 1000;
          };

          enableTCPIP = true;
          authentication = lib.mkOverride 10 ''
            # TYPE  DATABASE  USER  ADDRESS         METHOD
            local   all       all                   trust
            host    all       all   127.0.0.1/32    scram-sha-256
            host    all       all   ::1/128         scram-sha-256
          '';
        };

        # ── Redis (Shared Cache) ───────────────────────────────────────────
        services.redis.servers."main" = {
          enable = true;
          port = 6379;
          bind = "0.0.0.0"; # Simplicidad de Red: Bind global for LAN/Tailnet
        };

        # Open database ports inside the host firewall
        networking.firewall.allowedTCPPorts = lib.mkIf cfg.enable [ 5432 6379 ];

      };
    };
}
