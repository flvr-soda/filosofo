{ lib, mediaGroup, mediaPath, ... }: {
  flake.nixosModules.arr-stack = { config, pkgs, userName, ... }:
    let
      cfg = config.filosofo.features.arr-stack;
    in
    {
      options.filosofo.features.arr-stack = {
        enable = lib.mkEnableOption "Enable the full *ARR media automation stack";
      };

      config = lib.mkIf cfg.enable {
        # ── Reverse Proxy Registration ──────────────────────────────────────
        filosofo.services.proxy = {
          sonarr = { subdomain = "sonarr"; port = 8989; };
          radarr = { subdomain = "radarr"; port = 7878; };
          prowlarr = { subdomain = "prowlarr"; port = 9696; };
          lidarr = { subdomain = "lidarr"; port = 8686; };
          readarr = { subdomain = "readarr"; port = 8787; };
          bazarr = { subdomain = "bazarr"; port = 6767; };
          qbit = { subdomain = "qbit"; port = 8282; };
          seerr = { subdomain = "seerr"; port = 5055; };
          homarr = { subdomain = "homarr"; port = 7575; };
        };

        # ── Service Secrets ──────────────────────────────────────────────────

        age.secrets.homarr-secret-key = {
          file = ../../../secrets/homarr-secret-key.age;
          owner = "root";
          group = "root";
          mode = "0400";
        };

        # Shared media group for cross-service file access
        users.groups.${mediaGroup} = { };

        # Directory structure with correct ownership
        systemd.tmpfiles.rules = [
          "d ${mediaPath} 0775 ${userName} ${mediaGroup} - -"
          "d ${mediaPath}/downloads 0775 ${userName} ${mediaGroup} - -"
          "d ${mediaPath}/downloads/.incomplete 0775 ${userName} ${mediaGroup} - -"
          "d ${mediaPath}/movies 0775 ${userName} ${mediaGroup} - -"
          "d ${mediaPath}/shows 0775 ${userName} ${mediaGroup} - -"
          "d ${mediaPath}/books 0775 ${userName} ${mediaGroup} - -"
          "d ${mediaPath}/music 0775 ${userName} ${mediaGroup} - -"
          "d ${mediaPath}/comics 0775 ${userName} ${mediaGroup} - -"
          # Homarr persistent data
          "d /var/lib/homarr 0750 root root - -"
          "d /var/lib/homarr/configs 0750 root root - -"
          "d /var/lib/homarr/icons 0750 root root - -"
          "d /var/lib/homarr/data 0750 root root - -"
        ];

        # ── Indexers ──────────────────────────────────────────────
        services.prowlarr = {
          enable = true;
          openFirewall = false;
        };

        # ── TV / Movies ───────────────────────────────────────────
        services.sonarr = {
          enable = true;
          openFirewall = false;
          group = mediaGroup;
        };

        services.radarr = {
          enable = true;
          openFirewall = false;
          group = mediaGroup;
        };

        # ── Music / Books ─────────────────────────────────────────
        services.lidarr = {
          enable = true;
          openFirewall = false;
          group = mediaGroup;
        };

        services.readarr = {
          enable = true;
          openFirewall = false;
          group = mediaGroup;
        };

        # ── Music / Books (Relocated to navidrome.nix and kavita.nix) ──────

        # ── Subtitles ─────────────────────────────────────────────
        services.bazarr = {
          enable = true;
          openFirewall = false;
          group = mediaGroup;
        };

        # ── Downloader ────────────────────────────────────────────────
        users.users.qbittorrent-nox = {
          isSystemUser = true;
          group = "qbittorrent-nox";
          extraGroups = [ mediaGroup ];
        };
        users.groups.qbittorrent-nox = { };

        # ── Request Management ────────────────────────────────────
        services.seerr = {
          enable = true;
          openFirewall = false;
        };

        # ── Streaming Media Server (Relocated to jellyfin.nix) ────

        # ── Dashboard (OCI — no native NixOS service) ─────────────
        virtualisation.oci-containers.backend = lib.mkDefault "podman";
        virtualisation.oci-containers.containers.homarr = {
          image = "ghcr.io/homarr-labs/homarr:latest";
          ports = [ "7575:7575" ];
          volumes = [
            "/var/lib/homarr/configs:/app/data/configs"
            "/var/lib/homarr/icons:/app/public/icons"
            "/var/lib/homarr/data:/data"
          ];
          # Encryption key from agenix — prevents session hijacking
          environmentFiles = [ config.age.secrets.homarr-secret-key.path ];
        };

        # Firewall: qBittorrent peer port (6881)
        networking.firewall.allowedTCPPorts = [ 6881 ];
        networking.firewall.allowedUDPPorts = [ 6881 ];

        # ── Systemd Hardening & Services ──────────────────────────
        systemd.services = {
          "qbittorrent-nox" = {
            description = "qBittorrent-nox service";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
              ExecStart = "${pkgs.qbittorrent-enhanced-nox}/bin/qbittorrent-nox --webui-port=8282";
              User = "qbittorrent-nox";
              Group = "qbittorrent-nox";
              StateDirectory = "qbittorrent-nox";
              Restart = "on-failure";
              # Basic hardening for qBittorrent
              NoNewPrivileges = true;
              PrivateTmp = true;
              ReadWritePaths = [ mediaPath ];
            };
          };
        } // lib.genAttrs [
          "prowlarr" "sonarr" "radarr" "lidarr" "readarr" "bazarr"
        ] (svc: {
          serviceConfig = {
            StateDirectory = lib.mkDefault svc;
            # Use mkDefault so we don't break upstream module requirements
            NoNewPrivileges = lib.mkDefault true;
            PrivateTmp = lib.mkDefault true;
            ProtectSystem = lib.mkDefault "strict";
            ProtectHome = lib.mkDefault true;
            ReadWritePaths = [ mediaPath ];
          };
        });
      };
    };
}
