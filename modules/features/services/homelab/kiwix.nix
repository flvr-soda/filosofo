# kiwix.nix — Kiwix offline Wikipedia/ZIM server.
#
# Rules enforced:
#   ✓ Binds to 0.0.0.0 — no reverse proxy
#   ✓ Opens port 8081 atomically in the firewall
{ lib, ... }: {
  flake.nixosModules.kiwix = { config, pkgs, userName, ... }:
    let
      cfg     = config.filosofo.features.kiwix;
      port    = 8081;
      dataDir = "/var/lib/kiwix";
    in
    {
      options.filosofo.features.kiwix.enable =
        lib.mkEnableOption "Enable Kiwix offline ZIM content server";

      config = lib.mkIf cfg.enable {
        systemd.services.kiwix-serve = {
          description = "Kiwix ZIM content server";
          after       = [ "network.target" ];
          wantedBy    = [ "multi-user.target" ];
          serviceConfig = {
            # Bind globally — direct LAN + Tailscale access
            ExecStart      = "${pkgs.kiwix-tools}/bin/kiwix-serve --address 0.0.0.0 --port ${builtins.toString port} ${dataDir}/*.zim";
            Restart        = "always";
            User           = "kiwix";
            Group          = "kiwix";
            WorkingDirectory = dataDir;
            NoNewPrivileges  = true;
            PrivateTmp       = true;
            ProtectSystem    = "full";
            ProtectHome      = true;
          };
        };

        users.users.kiwix = { isSystemUser = true; group = "kiwix"; };
        users.groups.kiwix = { };

        systemd.tmpfiles.rules = [ "d ${dataDir} 0755 kiwix kiwix - -" ];

        networking.firewall.allowedTCPPorts = [ port ];

        home-manager.users.${userName} = { pkgs, ... }: {
          home.packages = [ pkgs.kiwix ];
        };
      };
    };
}
