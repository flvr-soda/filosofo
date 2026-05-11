{ lib, pkgs, mediaGroup, mediaPath, ... }: {
  flake.nixosModules.jellyfin = { config, pkgs, ... }:
    let
      cfg = config.filosofo.features.jellyfin;
    in
    {
      options.filosofo.features.jellyfin = {
        enable = lib.mkEnableOption "Enable Jellyfin media server";
      };

      config = lib.mkIf cfg.enable {
        filosofo.services.proxy.jellyfin = {
          subdomain = "jellyfin";
          port = 8096;
        };

        services.jellyfin = {
          enable = true;
          openFirewall = true;
          package = pkgs.jellyfin;
          user = "jellyfin";
          group = "jellyfin";
        };

        users.users.jellyfin.extraGroups = [ "render" "video" mediaGroup ];
        users.groups.${mediaGroup} = { };

      };
    };
}
