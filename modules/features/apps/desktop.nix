{ self, lib, ... }: {
  flake.nixosModules.noctaliaDesktop = { config, pkgs, ... }: {
    # Imports are always evaluated — they must be at the top level, never inside mkIf
    imports = [
      self.nixosModules.niri
      self.nixosModules.noctalia
      self.nixosModules.pipewire
      self.nixosModules.gtk
    ];

    options.filosofo.features.desktop.niri.enable = lib.mkEnableOption "Enable the Niri + Noctalia Desktop Environment";

    config = lib.mkIf config.filosofo.features.desktop.niri.enable {
      # Login manager — required to start a Wayland session
      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
            user = "greeter";
          };
        };
      };

      # Bluetooth configuration for the desktop
      hardware.bluetooth.enable = true;
      hardware.bluetooth.powerOnBoot = true;
    };

  };
}
