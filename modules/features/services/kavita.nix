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

        sops.secrets.kavita_token = {
          owner = "kavita";
          group = "kavita";
          mode = "0400";
        };

        services.kavita = {
          enable = true;
          tokenKeyFile = config.sops.secrets.kavita_token.path;
          settings = {
            IpAddresses = "127.0.0.1";
            Port = 5000;
          };
        };

      };
    };
}
