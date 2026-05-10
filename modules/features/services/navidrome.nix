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

        age.secrets.navidrome-password = {
          file = ../../../secrets/navidrome-password.age;
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
            PasswordEncryptionKey = config.age.secrets.navidrome-password.path;
          };
        };

        systemd.services.navidrome.serviceConfig = {
          StateDirectory = "navidrome";
          NoNewPrivileges = lib.mkDefault true;
          PrivateTmp = lib.mkDefault true;
          ProtectSystem = lib.mkDefault "strict";
          ProtectHome = lib.mkDefault true;
          ReadWritePaths = [ "${mediaPath}/music" ];
        };
      };
    };
}
