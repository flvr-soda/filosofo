{ lib, ... }:
{
  flake.nixosModules.kiwix =
    {
      config,
      pkgs,
      userName,
      ...
    }:
    let
      cfg = config.filosofo.features.kiwix;
      port = 8081;
      dataDir = "/var/lib/kiwix";
    in
    {
      options.filosofo.features.kiwix.enable = lib.mkEnableOption "Enable the Kiwix atomic feature";

      config = lib.mkIf cfg.enable {
        # ── Reverse Proxy Registration ──────────────────────────────────────
        filosofo.services.proxy.kiwix = {
          subdomain = "wiki";
          port = 8081;
        };

        # We use a custom service for predictable filesystem and startup behavior.
        systemd.services.kiwix-serve = {
          description = "Kiwix Server";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = "${pkgs.kiwix-tools}/bin/kiwix-serve --address 127.0.0.1 --port ${builtins.toString port} ${dataDir}/*.zim";
            Restart = "always";
            User = "kiwix";
            Group = "kiwix";
            WorkingDirectory = dataDir;
            NoNewPrivileges = true;
            PrivateTmp = true;
            ProtectSystem = "strict";
            ProtectHome = true;
          };
        };

        users.users.kiwix = {
          isSystemUser = true;
          group = "kiwix";
        };
        users.groups.kiwix = { };

        # Caddy handles external access via reverse proxy to localhost:8081
        # networking.firewall.allowedTCPPorts = [ port ];

        systemd.tmpfiles.rules = [ "d ${dataDir} 0755 kiwix kiwix - -" ];

        home-manager.users.${userName} = { pkgs, ... }: {
          home.packages = [ pkgs.kiwix ];
        };
      };
    };
}
