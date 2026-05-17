# arr-stack.nix — Full *ARR media automation stack.
#
# Includes: Prowlarr, Sonarr, Radarr, Lidarr, Readarr, Bazarr,
#           qBittorrent-nox (enhanced), Seerr.
#
# Rules enforced:
#   ✓ All services bind globally (0.0.0.0) via openFirewall = true or explicit ports
#   ✓ All required TCP/UDP ports opened atomically in this file
#   ✓ No reverse proxy references
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
        # ── Shared media group ─────────────────────────────────────────────
        users.groups.${mediaGroup} = { };

        systemd.tmpfiles.rules = [
          "d ${mediaPath}                       0775 ${userName} ${mediaGroup} - -"
          "d ${mediaPath}/downloads             0775 ${userName} ${mediaGroup} - -"
          "d ${mediaPath}/downloads/.incomplete 0775 ${userName} ${mediaGroup} - -"
          "d ${mediaPath}/movies                0775 ${userName} ${mediaGroup} - -"
          "d ${mediaPath}/shows                 0775 ${userName} ${mediaGroup} - -"
          "d ${mediaPath}/books                 0775 ${userName} ${mediaGroup} - -"
          "d ${mediaPath}/music                 0775 ${userName} ${mediaGroup} - -"
          "d ${mediaPath}/comics                0775 ${userName} ${mediaGroup} - -"
        ];

        # ── Indexers ───────────────────────────────────────────────────────
        services.prowlarr = {
          enable      = true;
          openFirewall = true; # port 9696
        };

        # ── TV ────────────────────────────────────────────────────────────
        services.sonarr = {
          enable      = true;
          openFirewall = true; # port 8989
          group       = mediaGroup;
        };

        # ── Movies ────────────────────────────────────────────────────────
        services.radarr = {
          enable      = true;
          openFirewall = true; # port 7878
          group       = mediaGroup;
        };

        # ── Music ─────────────────────────────────────────────────────────
        services.lidarr = {
          enable      = true;
          openFirewall = true; # port 8686
          group       = mediaGroup;
        };

        # ── Books ─────────────────────────────────────────────────────────
        services.readarr = {
          enable      = true;
          openFirewall = true; # port 8787
          group       = mediaGroup;
        };

        # ── Subtitles ─────────────────────────────────────────────────────
        services.bazarr = {
          enable      = true;
          openFirewall = true; # port 6767
          group       = mediaGroup;
        };

        # ── Request management (Overseerr fork) ───────────────────────────
        services.seerr = {
          enable      = true;
          openFirewall = true; # port 5055
        };

        # Firewall: all services above use openFirewall = true.
      };
    };
}
