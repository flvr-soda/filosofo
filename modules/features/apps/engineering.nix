# apps/engineering.nix — Hardware development environments.
# Taxonomy: features/apps/engineering.nix
# Covers: Arduino IDE/CLI, KiCad, Minicom + serial group membership + udev rules.
{ lib, ... }: {
  flake.nixosModules.engineering = { config, pkgs, userName, ... }:
    let
      cfg = config.filosofo.features.engineering;
    in
    {
      options.filosofo.features.engineering.enable =
        lib.mkEnableOption "Enable hardware engineering tools (Arduino, KiCad, serial comms)";

      config = lib.mkIf cfg.enable {
        # udev rules so the user can flash boards without root
        services.udev.packages = [ pkgs.arduino-ide ];

        users.users.${userName}.extraGroups = [ "dialout" "tty" ];

        home-manager.users.${userName} = { pkgs, ... }: {
          home.packages = with pkgs; [
            arduino-ide
            arduino-cli
            kicad
            minicom
            screen
            picocom
          ];
        };
      };
    };
}
