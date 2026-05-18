# arr-stack.nix — Full *ARR media automation stack.

# Rules enforced:
#   ✓ All services bind globally (0.0.0.0) via openFirewall = true or explicit ports
#   ✓ All required TCP/UDP ports opened atomically in this file

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

        services.prowlarr = {
          enable      = true;
          openFirewall = true;
        };

        services.sonarr = {
          enable      = true;
          openFirewall = true;
          group       = mediaGroup;
        };

        services.radarr = {
          enable      = true;
          openFirewall = true;
          group       = mediaGroup;
        };

        services.lidarr = {
          enable      = true;
          openFirewall = true;
          group       = mediaGroup;
        };

        services.readarr = {
          enable      = true;
          openFirewall = true;
          group       = mediaGroup;
        };

        services.bazarr = {
          enable      = true;
          openFirewall = true;
          group       = mediaGroup;
        };

        services.seerr = {
          enable      = true;
          openFirewall = true;
        };
      };
    };
}
