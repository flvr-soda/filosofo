{ lib, ... }: {
  flake.nixosModules.pihole =
    { config, ... }:
    let
      cfg = config.filosofo.features.pihole;
      webPort = 8085;
    in
    {
      options.filosofo.features.pihole.enable = lib.mkEnableOption "Enable the Pi-hole atomic feature";

      config = lib.mkIf cfg.enable {
        # ── Reverse Proxy Registration ──────────────────────────────────────
        filosofo.services.proxy.pihole = {
          subdomain = "pihole";
          port = webPort;
        };

        # systemd-resolved also listens on port 53 by default. Disable the stub
        # listener so pihole can bind 0.0.0.0:53 without a port conflict.
        # Resolved still runs for DNS caching; it just hands off to pihole.
        services.resolved.settings = {
          Resolve = {
            DNS = [ "127.0.0.1" ];
            DNSStubListener = "no";
          };
        };

        virtualisation.oci-containers.backend = lib.mkDefault "podman";

        virtualisation.oci-containers.containers.pihole = {
          image = "pihole/pihole:latest";
          ports = [
            "53:53/tcp"
            "53:53/udp"
            "67:67/udp"
            "127.0.0.1:${builtins.toString webPort}:80/tcp"
          ];
          volumes = [
            "/var/lib/pihole/etc-pihole:/etc/pihole"
            "/var/lib/pihole/etc-dnsmasq.d:/etc/dnsmasq.d"
          ];
          environment = {
            TZ = config.time.timeZone;
            DNSMASQ_LISTENING = "all";
            WEB_PORT = builtins.toString webPort;
          };
          extraOptions = [ "--cap-add=NET_ADMIN" "--pull=always" ];
        };

        systemd.tmpfiles.rules = [
          "d /var/lib/pihole 0750 root root - -"
          "d /var/lib/pihole/etc-pihole 0750 root root - -"
          "d /var/lib/pihole/etc-dnsmasq.d 0750 root root - -"
        ];

        networking.firewall.allowedTCPPorts = [ 53 ];
        networking.firewall.allowedUDPPorts = [ 53 67 ];
      };
    };
}

