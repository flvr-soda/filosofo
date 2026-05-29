{ lib, ... }: {
  flake.nixosModules.immich = { config, ... }:
    let
      cfg = config.filosofo.features.immich;
    in
    {
      options.filosofo.features.immich = {
        enable = lib.mkEnableOption "Enable Immich photo backup and management";
      };

      config = lib.mkIf cfg.enable {
        services.immich = {
          enable = true;
          port = 2283;
          host = "0.0.0.0";
          machine-learning.enable = true;
        };
      };
    };
}
