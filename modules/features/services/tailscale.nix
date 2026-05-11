# Tailscale VPN — atomic feature: network config + firewall + service
# Per prompt.md: "Tailscale VPN = network config + firewall + secrets + certificates"
{ lib, ... }: {
  flake.nixosModules.tailscale = { config, pkgs, ... }:
    let
      cfg = config.filosofo.features.tailscale;
    in
    {
      options.filosofo.features.tailscale = {
        enable = lib.mkEnableOption "Enable Tailscale zero-config VPN";
        useRoutingFeatures = lib.mkOption {
          type = lib.types.enum [ "none" "client" "server" "both" ];
          default = "client";
          description = "Enable subnet routing or exit node features";
        };
        # When true, the sops-managed tailscale_authkey secret is used
        headlessJoin = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Use the sops tailscale_authkey secret for headless node registration";
        };
      };

      config = lib.mkIf cfg.enable {
        sops.secrets.tailscale_authkey = lib.mkIf cfg.headlessJoin {
          owner = "root";
          group = "root";
          mode = "0400";
        };

        services.tailscale = {
          enable = true;
          openFirewall = true;
          useRoutingFeatures = cfg.useRoutingFeatures;
        } // lib.optionalAttrs cfg.headlessJoin {
          authKeyFile = config.sops.secrets.tailscale_authkey.path;
        };

        # Allow Tailscale traffic through the firewall
        networking.firewall = {
          trustedInterfaces = [ "tailscale0" ];
          # Allow incoming connections from Tailscale network
          allowedUDPPorts = [ config.services.tailscale.port ];
        };

        # Ensure IP forwarding is enabled for subnet routing / exit nodes
        boot.kernel.sysctl = lib.mkIf (cfg.useRoutingFeatures != "none") {
          "net.ipv4.ip_forward" = 1;
          "net.ipv6.conf.all.forwarding" = 1;
        };

        environment.systemPackages = [ pkgs.tailscale ];
      };
    };
}
