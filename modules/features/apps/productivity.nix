{ lib, ... }: {
  flake.nixosModules.productivity = { config, pkgs, userName, ... }:
    let
      cfg = config.filosofo.features.productivity;
    in
    {
      options.filosofo.features.productivity.enable =
        lib.mkEnableOption "Enable productivity tools";

      config = lib.mkIf cfg.enable {
        home-manager.users.${userName} = { pkgs, ... }: {
          home.packages = with pkgs; [
            onlyoffice-desktopeditors
            obsidian
            zotero
          ];
        };
      };
    };
}
