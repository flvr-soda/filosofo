{ lib, pkgs, mediaPath, ... }: {
  flake.nixosModules.kavita = { config, pkgs, ... }:
    let
      cfg = config.filosofo.features.kavita;
    in
    {
      options.filosofo.features.kavita = {
        enable = lib.mkEnableOption "Enable Kavita digital library";
      };

      config = lib.mkIf cfg.enable {
        filosofo.services.proxy.kavita = {
          subdomain = "kavita";
          port = 5000;
        };

        age.secrets.kavita-token = {
          file = ../../../secrets/kavita-token.age;
          owner = "kavita";
          group = "kavita";
          mode = "0400";
        };

        services.kavita = {
          enable = true;
          tokenKeyFile = config.age.secrets.kavita-token.path;
          settings = {
            IpAddresses = "127.0.0.1";
            Port = 5000;
          };
        };

        systemd.services.kavita.serviceConfig = {
          StateDirectory = "kavita";
          NoNewPrivileges = lib.mkDefault true;
          PrivateTmp = lib.mkDefault true;
          ProtectSystem = lib.mkDefault "strict";
          ProtectHome = lib.mkDefault true;
          ReadWritePaths = [ "${mediaPath}/books" "${mediaPath}/comics" ];
        };
      };
    };
}
