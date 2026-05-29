# Cloudflare WARP — optional external VPN tunnel
# Interface name: CloudflareWARP (created by warp-svc daemon)
{ lib, ... }: {
  flake.nixosModules.cloudflare-warp = { config, ... }:
    let
      cfg = config.filosofo.features.cloudflare-warp;
    in
    {
      options.filosofo.features.cloudflare-warp = {
        enable = lib.mkEnableOption "Enable Cloudflare WARP external VPN";

        interfaceName = lib.mkOption {
          type    = lib.types.str;
          default = "CloudflareWARP";
          description = "Network interface name created by the Cloudflare WARP daemon.";
        };
      };

      config = lib.mkIf cfg.enable {
        services.cloudflare-warp.enable = true;

        # Trust the WARP tunnel interface so the NixOS firewall does not
        # inspect or block traffic routed through Cloudflare's network.
        networking.firewall.trustedInterfaces = [ cfg.interfaceName ];

        # Ensure warp-svc starts before any service that may bind to its interface.
        systemd.services.cloudflare-warp.wantedBy = [ "multi-user.target" ];
      };
    };
}
