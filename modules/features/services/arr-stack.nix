{ lib, mediaGroup, mediaPath, ... }: {
  flake.nixosModules.arr-stack = { config, pkgs, userName, ... }:
    let
      cfg = config.filosofo.features.arr-stack;
    in
    {
      options.filosofo.features.arr-stack = {
        enable = lib.mkEnableOption "Enable the full *ARR media automation stack";
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
        ];

        # ── Indexers ──────────────────────────────────────────────
        services.prowlarr = {
          enable = true;
          openFirewall = true;
          port = 9696;
        };

        # ── TV / Movies ───────────────────────────────────────────
        services.sonarr = {
          enable = true;
          openFirewall = true;
          group = mediaGroup;
        };

        services.radarr = {
          enable = true;
          openFirewall = true;
          group = mediaGroup;
          port = 7878;
        };

        # ── Music / Books ─────────────────────────────────────────
        services.lidarr = {
          enable = true;
          openFirewall = true;
          group = mediaGroup;
          port = 8686;
        };

        services.readarr = {
          enable = true;
          openFirewall = true;
          group = mediaGroup;
          port = 8787;
        };

        # ── Music / Books (Relocated to navidrome.nix and kavita.nix) ──────

        # ── Subtitles ─────────────────────────────────────────────
        services.bazarr = {
          enable = true;
          openFirewall = true;
          group = mediaGroup;
          port = 6767;
        };

        # ── Downloader ────────────────────────────────────────────────
        users.users.qbittorrent-nox = {
          isSystemUser = true;
          group = "qbittorrent-nox";
          extraGroups = [ mediaGroup ];
          home = "/var/lib/qbittorrent-nox";
          createHome = true;
          port = 8282;
        };
        users.groups.qbittorrent-nox = { };

        # ── Request Management ────────────────────────────────────
        services.seerr = {
          enable = true;
          openFirewall = true;
          port = 5055;
        };

        # Automation-only stack: *ARR, downloader, request UI, Homarr dashboard.
        # Streaming servers live in jellyfin.nix, kavita.nix, navidrome.nix.

        # Firewall: qBittorrent peer port (6881)
        networking.firewall.allowedTCPPorts = [ 6881 ];
        networking.firewall.allowedUDPPorts = [ 6881 ];

    };
}
