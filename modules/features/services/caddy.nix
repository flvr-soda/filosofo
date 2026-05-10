# Caddy — automatic HTTPS reverse proxy for all self-hosted services
# Per prompt.md: "Caddy: Automatic HTTPS reverse proxy"
{ lib, ... }: {
  flake.nixosModules.caddy = { config, ... }:
    let
      cfg = config.filosofo.features.caddy;
    in
    {
      options.filosofo.features.caddy = {
        enable = lib.mkEnableOption "Enable Caddy reverse proxy";
        domain = lib.mkOption {
          type = lib.types.str;
          default = "filosofo.lan";
          description = "Base domain for reverse proxy virtual hosts";
        };
      };

      config = lib.mkIf cfg.enable {
        services.caddy = {
          enable = true;

          # Build virtual hosts from enabled services
          virtualHosts = let
            # Dynamic proxy registration via discovery mechanism
            discoveredProxies = lib.mapAttrs' (name: proxy: 
              lib.nameValuePair "${proxy.subdomain}.${cfg.domain}" {
                extraConfig = ''
                  reverse_proxy localhost:${toString proxy.port}
                '';
              }
            ) (lib.filterAttrs (name: proxy: proxy.enable) config.filosofo.services.proxy);
          in {
            # Base configuration
          } // discoveredProxies;
        };

        # Caddy needs ports 80 and 443
        networking.firewall.allowedTCPPorts = [ 80 443 ];

        # Systemd hardening for Caddy
        systemd.services.caddy.serviceConfig = {
          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectHome = true;
          ProtectSystem = "strict";
          ReadWritePaths = [ "/var/lib/caddy" "/var/log/caddy" ];
        };
      };
    };
}
