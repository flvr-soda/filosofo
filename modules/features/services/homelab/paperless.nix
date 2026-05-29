{ lib, ... }: {
  flake.nixosModules.paperless = { config, ... }:
    let
      cfg = config.filosofo.features.paperless;
    in
    {
      options.filosofo.features.paperless = {
        enable = lib.mkEnableOption "Enable Paperless-ngx document management";
      };

      config = lib.mkIf cfg.enable {
        services.paperless = {
          enable = true;
          port = 28981;
          address = "0.0.0.0";
          settings = {
            PAPERLESS_OCR_LANGUAGE = "eng";
            PAPERLESS_ADMIN_USER = "admin";
          };
        };
      };
    };
}
