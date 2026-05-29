# Netbird VPN — atomic feature: network config + firewall + service
{ lib, ... }: {
  flake.nixosModules.netbird = { config, pkgs, ... }:
    let
      cfg = config.filosofo.features.netbird;
    in
    {
      options.filosofo.features.netbird = {
        enable = lib.mkEnableOption "Enable Netbird zero-config VPN";
        useRoutingFeatures = lib.mkOption {
          type = lib.types.enum [ "none" "client" "server" "both" ];
          default = "client";
          description = "Enable subnet routing or exit node features";
        };
      };

      config = lib.mkIf cfg.enable {
        services.netbird = {
          enable = true;
        };

        networking.firewall = {
          trustedInterfaces = [ "wt0" ];
        };

        # Ensure IP forwarding is enabled for subnet routing / exit nodes.
        # rp_filter is set to loose mode (2) here because core/networking.nix sets
        # strict mode (1) globally. Strict mode silently drops packets that arrive
        # on wt0 but are routed out via another interface — breaking subnet routing
        # and exit-node functionality on server hosts.
        # Loose mode still protects against spoofed source addresses.
        boot.kernel.sysctl = lib.mkIf (cfg.useRoutingFeatures != "none") {
          "net.ipv4.ip_forward"                = 1;
          "net.ipv6.conf.all.forwarding"       = 1;
          "net.ipv4.conf.all.rp_filter"        = lib.mkOverride 90 2;
          "net.ipv4.conf.default.rp_filter"    = lib.mkOverride 90 2;
          "net.ipv4.conf.wt0.rp_filter"        = lib.mkOverride 90 2;
        };

        environment.systemPackages = [ pkgs.netbird ];
      };
    };
}
