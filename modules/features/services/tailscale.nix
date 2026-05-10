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
        # When true, the agenix-managed tailscale-authkey secret is used
        # so the node joins the tailnet automatically on first boot.
        headlessJoin = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Use the agenix tailscale-authkey secret for headless node registration";
        };
      };

      config = lib.mkIf cfg.enable {
        age.secrets.tailscale-authkey = {
          file = ../../../secrets/tailscale-authkey.age;
          owner = "root";
          group = "root";
          mode = "0400";
        };

        services.tailscale = {
          enable = true;
          openFirewall = true;
          useRoutingFeatures = cfg.useRoutingFeatures;
          # Wire the agenix secret only when headless join is requested.
          # On interactive machines (laptop/desktop) this stays null so the
          # user can run `tailscale up` manually with their chosen options.
          authKeyFile = lib.mkIf cfg.headlessJoin
            config.age.secrets.tailscale-authkey.path;
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
