{ lib, ... }: {
  flake.nixosModules.database-clients = { config, userName, ... }:
    let
      cfg = config.filosofo.features.database-clients;
    in
    {
      options.filosofo.features.database-clients.enable =
        lib.mkEnableOption "Enable database clients";

      config = lib.mkIf cfg.enable {
        home-manager.users.${userName} = { pkgs, ... }: {
          home.packages = with pkgs; [
            beekeeper-studio
            postgresql_16 # psql CLI
          ];
        };
      };
    };
}
