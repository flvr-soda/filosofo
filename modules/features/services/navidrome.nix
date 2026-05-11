{ lib, pkgs, mediaPath, ... }: {
  flake.nixosModules.navidrome = { config, pkgs, ... }:
    let
      cfg = config.filosofo.features.navidrome;
    in
    {
      options.filosofo.features.navidrome = {
        enable = lib.mkEnableOption "Enable Navidrome music server";
      };

      config = lib.mkIf cfg.enable {
        filosofo.services.proxy.navidrome = {
          subdomain = "navidrome";
          port = 4533;
        };

        sops.secrets.navidrome_password = {
          owner = "navidrome";
          group = "navidrome";
          mode = "0400";
        };

        services.navidrome = {
          enable = true;
          openFirewall = false;
          settings = {
            MusicFolder = "${mediaPath}/music";
            Address = "127.0.0.1";
            Port = 4533;
            PasswordEncryptionKey = config.sops.secrets.navidrome_password.path;
          };
        };

      };
    };
}
