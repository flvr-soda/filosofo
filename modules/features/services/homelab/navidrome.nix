# navidrome.nix — Navidrome music streaming server.
#
# Rules enforced:
#   ✓ Binds to 0.0.0.0 — no reverse proxy
#   ✓ Opens port 4533 atomically in the firewall
{ lib, mediaPath, ... }: {
  flake.nixosModules.navidrome = { config, ... }:
    let
      cfg = config.filosofo.features.navidrome;
    in
    {
      options.filosofo.features.navidrome = {
        enable = lib.mkEnableOption "Enable Navidrome music streaming server";
      };

      config = lib.mkIf cfg.enable {
        services.navidrome = {
          enable      = true;
          openFirewall = false; # We open the port manually below for clarity
          settings    = {
            MusicFolder = "${mediaPath}/music";
            Address     = "0.0.0.0";
            Port        = 4533;
          };
        };

        networking.firewall.allowedTCPPorts = [ 4533 ];
      };
    };
}
