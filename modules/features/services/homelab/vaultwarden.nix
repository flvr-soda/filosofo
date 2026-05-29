{ lib, ... }: {
  flake.nixosModules.vaultwarden = { config, ... }:
    let
      cfg = config.filosofo.features.vaultwarden;
    in
    {
      options.filosofo.features.vaultwarden = {
        enable = lib.mkEnableOption "Enable Vaultwarden (Bitwarden compatible server)";
      };

      config = lib.mkIf cfg.enable {
        services.vaultwarden = {
          enable = true;
          config = {
            DOMAIN = "http://localhost:8222"; # Update to actual domain later
            SIGNUPS_ALLOWED = false;
            ROCKET_PORT = 8222;
            ROCKET_ADDRESS = "0.0.0.0";
          };
        };
      };
    };
}
