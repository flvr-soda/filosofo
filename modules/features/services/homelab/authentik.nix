{ lib, ... }: {
  flake.nixosModules.authentik = { config, ... }:
    let
      cfg = config.filosofo.features.authentik;
    in
    {
      options.filosofo.features.authentik = {
        enable = lib.mkEnableOption "Enable Authentik SSO";
      };

      config = lib.mkIf cfg.enable {
        # Note: If this fails to evaluate due to missing package in this specific nixpkgs commit, 
        # fallback to the OCI container method from the reference.
        services.authentik = {
          enable = true;
          environmentFile = "/persist/secrets/authentik-env";
          # Port setup (default is usually 9000 for http)
          settings = {
            disable_startup_analytics = true;
            avatars = "none";
          };
        };
      };
    };
}
