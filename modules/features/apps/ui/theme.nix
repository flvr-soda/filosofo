# apps/ui/theme.nix — Theme, fonts, and dconf profile configurations
{ ... }: {
  flake.nixosModules.ui-theme = { config, pkgs, lib, ... }:
    let
      cfg = config.filosofo.features.desktop.niri;

      themeName    = "Gruvbox-Green-Dark-Medium";
      themePackage = pkgs.gruvbox-gtk-theme.override {
        colorVariants = [ "dark" ];
        sizeVariants  = [ "standard" ];
        themeVariants  = [ "green" ];
        tweakVariants  = [ "medium" "macos" ];
      };
      iconName     = "Gruvbox-Plus-Dark";
      iconPackage  = pkgs.gruvbox-plus-icons;
      gtkIni       = ''
        [Settings]
        gtk-icon-theme-name = ${iconName}
        gtk-theme-name = ${themeName}
        gtk-application-prefer-dark-theme = 1
      '';
    in
    {
      config = lib.mkIf cfg.enable {
        environment.systemPackages = [
          themePackage
          iconPackage
          pkgs.adwaita-icon-theme
          pkgs.pavucontrol
        ];

        environment.etc = {
          "xdg/gtk-3.0/settings.ini".text = gtkIni;
          "xdg/gtk-4.0/settings.ini".text = gtkIni;
        };

        environment.variables = {
          GTK_THEME = themeName;
          XCURSOR_THEME = "Adwaita";
          XCURSOR_SIZE = "24";
        };

        programs.dconf = {
          enable = true;
          profiles.user.databases = [{
            lockAll = false;
            settings."org/gnome/desktop/interface" = {
              gtk-theme    = themeName;
              icon-theme   = iconName;
              cursor-theme = "Adwaita";
              color-scheme = "prefer-dark";
            };
          }];
        };

        fonts = {
          packages = with pkgs; [
            font-awesome
            powerline-fonts
            powerline-symbols
            nerd-fonts.jetbrains-mono
            nerd-fonts.symbols-only
            noto-fonts
            noto-fonts-cjk-sans
            noto-fonts-color-emoji
            ubuntu-sans
          ];
          fontconfig.defaultFonts = {
            serif     = [ "Ubuntu Sans" ];
            sansSerif = [ "Ubuntu Sans" ];
            monospace = [ "JetBrainsMono Nerd Font" ];
          };
        };
      };
    };
}
