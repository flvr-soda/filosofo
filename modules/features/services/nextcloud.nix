{ lib, ... }: {
  flake.nixosModules.nextcloud =
    { config, pkgs, ... }:
    let
      cfg = config.filosofo.features.nextcloud;
      dataDir = "/var/lib/nextcloud-data";
    in
    {
      options.filosofo.features.nextcloud = {
        enable = lib.mkEnableOption "Enable the Nextcloud atomic feature";
        hostName = lib.mkOption {
          type = lib.types.str;
          default = "cloud.filosofo.lan";
          description = "Hostname for the Nextcloud virtual host";
        };
      };

      config = lib.mkIf cfg.enable {
        # ── Reverse Proxy Registration ──────────────────────────────────────
        filosofo.services.proxy.nextcloud = {
          subdomain = "cloud";
          port = 8080;
        };

        # ── Service Secrets ──────────────────────────────────────────────────
        age.secrets.nextcloud-admin-password = {
          file = ../../../secrets/nextcloud-admin-password.age;
          owner = "nextcloud";
          group = "nextcloud";
          mode = "0400";
        };

        services.nextcloud = {
          enable = true;
          package = pkgs.nextcloud33;
          hostName = cfg.hostName;
          https = false;
          configureRedis = true;
          database.createLocally = true;
          config = {
            dbtype = "pgsql";
            adminuser = "admin";
            # Admin password managed by agenix — set on first install only.
            # Nextcloud reads this file during initial setup.
            adminpassFile = config.age.secrets.nextcloud-admin-password.path;
          };
          settings = {
            default_phone_region = "VE";
            trusted_domains = [ cfg.hostName "localhost" ];
            # Force HTTPS for links when behind Caddy
            overwriteprotocol = "https";
            # Disable the log file (use journald instead)
            log_type = "errorlog";
          };
          maxUploadSize = "16G";
          datadir = dataDir;
        };

        # PostgreSQL is enabled by nextcloud's database.createLocally = true.
        # If databases.nix is also enabled, its lib.mkDefault ensureDatabases
        # list will merge cleanly with nextcloud's internally managed DB.
        services.redis.servers.nextcloud = {
          enable = true;
          user = "nextcloud";
        };

        systemd.tmpfiles.rules = [ "d ${dataDir} 0750 nextcloud nextcloud - -" ];

        # Force Nextcloud's internal webserver to only listen on localhost:8080
        # This prevents it from conflicting with Caddy on port 80 and forces traffic through the proxy.
        services.nginx.virtualHosts.${cfg.hostName}.listen = [
          { addr = "127.0.0.1"; port = 8080; }
        ];

        # Systemd Hardening
        systemd.services = lib.genAttrs [ "phpfpm-nextcloud" "nextcloud-cron" ] (svc: {
          serviceConfig = {
            NoNewPrivileges = lib.mkDefault true;
            PrivateTmp = lib.mkDefault true;
            ProtectSystem = lib.mkDefault "strict";
            ProtectHome = lib.mkDefault true;
            ReadWritePaths = [ dataDir "/var/lib/nextcloud" "/run/nextcloud" ];
          };
        });
      };
    };
}

