# apps/ui/default.nix — Master Desktop/UI Switch
{ self, lib, ... }: {
  flake.nixosModules.ui = { config, pkgs, userName, ... }:
    let
      cfg = config.filosofo.features.desktop.niri;
    in
    {
      imports = [
        self.nixosModules.ui-niri
        self.nixosModules.ui-noctalia
        self.nixosModules.ui-theme
      ];

      options.filosofo.features.desktop = {
        niri.enable = lib.mkEnableOption "Enable Niri + Noctalia desktop environment";
        autologin.enable = lib.mkEnableOption "Enable automatic login for the primary user";
      };

      config = lib.mkIf cfg.enable {
        # Core hardware/IPC services activated automatically by desktop environment
        filosofo.core = {
          audio.enable     = lib.mkDefault true;
          bluetooth.enable = lib.mkDefault true;
          dbus.enable      = lib.mkDefault true;
        };

        services.greetd = {
          enable   = true;
          settings = {
            initial_session = lib.mkIf config.filosofo.features.desktop.autologin.enable {
              command = "niri";
              user    = userName;
            };
            default_session = {
              command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri";
              user    = "greeter";
            };
          };
        };

        services.flatpak.enable = true;
        
        xdg.portal = {
          enable = true;
          extraPortals = [ pkgs.xdg-desktop-portal-gnome pkgs.xdg-desktop-portal-gtk ];
          config.common.default = "*";
        };

        home-manager.users.${userName} = { ... }: {
          xdg.configFile."fastfetch/config.jsonc".text =
            builtins.replaceStrings [ "__RHER_IMAGE__" ] [ "${./../assets/rher.png}" ] (builtins.readFile ../assets/fastfetch.json);
        };
      };
    };
}
