# kavita.nix — Kavita digital library server (books, comics, manga).
#
# Rules enforced:
#   ✓ Binds to 0.0.0.0 — no reverse proxy
#   ✓ Opens port 5000 atomically in the firewall
{ lib, mediaPath, ... }: {
  flake.nixosModules.kavita = { config, ... }:
    let
      cfg = config.filosofo.features.kavita;
    in
    {
      options.filosofo.features.kavita = {
        enable = lib.mkEnableOption "Enable Kavita digital library server";
      };

      config = lib.mkIf cfg.enable {
        sops.secrets.kavita_token = {
          owner = "kavita";
          group = "kavita";
          mode  = "0400";
        };

        services.kavita = {
          enable       = true;
          tokenKeyFile = config.sops.secrets.kavita_token.path;
          settings     = {
            # Bind globally — direct LAN + Tailscale access
            IpAddresses = "0.0.0.0,::";
            Port        = 5000;
          };
        };

        networking.firewall.allowedTCPPorts = [ 5000 ];
      };
    };
}
