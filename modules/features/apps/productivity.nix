{ self, inputs, lib, ... }: {
  flake.nixosModules.productivity = { config, userName, ... }: {
    options.filosofo.features.productivity.enable = lib.mkEnableOption "Enable office and productivity tools";

    config = lib.mkIf config.filosofo.features.productivity.enable {
      home-manager.users.${userName} = { pkgs, ... }: {
        home.packages = with pkgs; [
          onlyoffice-desktopeditors
          obsidian
          zathura
          # Add other productivity tools here
        ];
      };
    };
  };
}
