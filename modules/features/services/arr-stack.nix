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

        # ── Service Secrets (sops-nix; keys in secrets/secrets.yaml) ───────

        sops.secrets.homarr_secret_key = {
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
          home = "/var/lib/qbittorrent-nox";
          createHome = true;
        };
        users.groups.qbittorrent-nox = { };

        # ── Request Management ────────────────────────────────────
        services.seerr = {
          enable = true;
          openFirewall = false;
        };

        # Automation-only stack: *ARR, downloader, request UI, Homarr dashboard.
        # Streaming servers live in jellyfin.nix, kavita.nix, navidrome.nix.

        # ── Dashboard (OCI — no native NixOS service) ─────────────
        virtualisation.oci-containers.backend = lib.mkDefault "podman";
        virtualisation.oci-containers.containers.homarr = {
          # Pinned digest (same tag as :latest at pin time); bump intentionally when upgrading Homarr
          image = "ghcr.io/homarr-labs/homarr@sha256:6a726c72b37d56a7ce271d35498712f90bfd05ee203bc81e069d718489c35b06";
          ports = [ "7575:7575" ];
          volumes = [
            "/var/lib/homarr/configs:/app/data/configs"
            "/var/lib/homarr/icons:/app/public/icons"
            "/var/lib/homarr/data:/data"
          ];
          # Session encryption (SECRET_ENCRYPTION_KEY=…) from sops
          environmentFiles = [ config.sops.secrets.homarr_secret_key.path ];
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
              ExecStart = "${pkgs.qbittorrent-enhanced-nox}/bin/qbittorrent-nox --webui-port=8282 --confirm-legal-notice";
              User = "qbittorrent-nox";
              Group = "qbittorrent-nox";
              StateDirectory = "qbittorrent-nox";
              Environment = [
                "HOME=/var/lib/qbittorrent-nox"
                "QT_QPA_PLATFORM=offscreen"
              ];
              Restart = "on-failure";
            };
          };
        };
      };
    };
}
