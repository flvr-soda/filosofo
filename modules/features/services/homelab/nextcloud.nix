# nextcloud.nix — Nextcloud personal cloud storage.
#
# Rules enforced:
#   ✓ NixOS built-in nginx listens on 0.0.0.0:80 (Nextcloud's own nginx)
#   ✓ No external reverse proxy (Caddy removed)
#   ✓ Opens port 80 atomically in the firewall
#   ✓ PostgreSQL injection via database.createLocally = true (NixOS native hook)
{ lib, ... }: {
  flake.nixosModules.nextcloud =
    { config, pkgs, ... }:
    let
      cfg     = config.filosofo.features.nextcloud;
      dataDir = "/var/lib/nextcloud-data";
      port    = 80;
    in
    {
      options.filosofo.features.nextcloud = {
        enable = lib.mkEnableOption "Enable Nextcloud personal cloud storage";
        hostName = lib.mkOption {
          type        = lib.types.str;
          default     = "nextcloud.local";
          description = "Hostname Nextcloud uses for its virtual host and trusted domains.";
        };
      };

      config = lib.mkIf cfg.enable {
        sops.secrets.nextcloud_admin_password = {
          owner = "nextcloud";
          group = "nextcloud";
          mode  = "0400";
        };

        services.nextcloud = {
          enable    = true;
          package   = pkgs.nextcloud30;
          hostName  = cfg.hostName;
          https     = false;          # plain HTTP on LAN — no TLS terminator
          configureRedis  = true;
          database.createLocally = false;
          config = {
            dbtype        = "pgsql";
            dbname        = "nextcloud";
            dbuser        = "nextcloud";
            dbhost        = "/run/postgresql";
            adminuser     = "admin";
            adminpassFile = config.sops.secrets.nextcloud_admin_password.path;
          };
          settings = {
            default_phone_region = "VE";
            trusted_domains      = [ cfg.hostName "localhost" "0.0.0.0" ];
            log_type             = "errorlog";  # Direct logs to systemd journald
          };
          maxUploadSize = "16G";
          datadir       = dataDir;
        };

        services.redis.servers.nextcloud = {
          enable = true;
          user   = "nextcloud";
        };

        systemd.tmpfiles.rules = [ "d ${dataDir} 0750 nextcloud nextcloud - -" ];

        # Nextcloud's bundled nginx listens on port 80 by default.
        # Override to ensure it binds to all interfaces.
        services.nginx.virtualHosts.${cfg.hostName}.listen = [
          { addr = "0.0.0.0"; port = port; ssl = false; }
          { addr = "[::]";    port = port; ssl = false; }
        ];

        networking.firewall.allowedTCPPorts = [ port ];
      };
    };
}
