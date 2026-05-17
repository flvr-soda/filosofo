{ lib, ... }: {
  flake.nixosModules.database-clients = { config, pkgs, userName, ... }:
    let
      cfg = config.filosofo.features.database-clients;
    in
    {
      options.filosofo.features.database-clients.enable =
        lib.mkEnableOption "Enable database clients (DBeaver)";

      config = lib.mkIf cfg.enable {
        home-manager.users.${userName} = { pkgs, ... }: {
          home.packages = with pkgs; [
            dbeaver-bin
            postgresql_16 # psql CLI
          ];
        };
      };
    };
}
