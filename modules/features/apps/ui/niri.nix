# apps/ui/niri.nix — Niri WM and wlr-which-key wrapper
{ self, inputs, xkbLayout, xkbOptions, lib, ... }: {
  flake.nixosModules.ui-niri = { config, pkgs, lib, ... }:
    let
      cfg = config.filosofo.features.desktop.niri;
    in
    {
      config = lib.mkIf cfg.enable {
        programs.niri = {
          enable  = true;
          package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
        };

        environment.systemPackages = with pkgs; [
          self.packages.${pkgs.stdenv.hostPlatform.system}.which-key
          nautilus
          awww # Wallpaper daemon
          wayland-utils
          wl-clipboard
          libnotify
          brightnessctl
          grim
          slurp
          swappy
        ];
      };
    };

  perSystem = { pkgs, ... }: {
    packages = {
      niri = inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;
        v2-settings = true;
        settings = {
          input = {
            keyboard = {
              xkb = {
                layout = xkbLayout;
                options = xkbOptions;
              };
            };
            touchpad = {
              tap = {};
              dwt = {};
            };
            mouse = {
              accel-speed = 0.2;
            };
          };

          layout = {
            gaps = 12;
            center-focused-column = "never";
            preset-column-widths = [
              { proportion = 1.0 / 3.0; }
              { proportion = 1.0 / 2.0; }
              { proportion = 2.0 / 3.0; }
            ];
            default-column-width = { proportion = 1.0 / 2.0; };
            focus-ring = {
              width = 4;
              active-color = "#fabd2f";
              inactive-color = "#504945";
            };
            border = {
              off = {};
            };
          };

          spawn-at-startup = [
            [ "noctalia-shell" ]
            [ "awww-daemon" ]
            [ "awww" "img" "${./../assets/walls/w10.jpg}" ]
          ];

          environment = {
            "QT_QPA_PLATFORM" = "wayland";
            "DISPLAY" = ":0";
          };

          cursor = {
            xcursor-theme = "Adwaita";
            xcursor-size = 24;
          };
          
          binds = {
            "Mod+Return".spawn = "kitty";
            "Mod+Space".spawn = [ "noctalia-shell" "app-launcher" "toggle" ];
            "Mod+Shift+Space".switch-preset-keyboard-layout = "next";
            "Mod+Shift+Slash".spawn = "which-key";
            "Mod+Q".close-window = _: {};

            "Mod+Ctrl+H".set-column-width = "-5%";
            "Mod+Ctrl+L".set-column-width = "+5%";
            "Mod+Ctrl+J".set-window-height = "-5%";
            "Mod+Ctrl+K".set-window-height = "+5%";
            "Mod+Shift+T".toggle-window-floating = _: {};

            "Mod+Ctrl+S".spawn = [ "sh" "-c" "${lib.getExe pkgs.grim} -l 0 - | ${pkgs.wl-clipboard}/bin/wl-copy" ];
            "Mod+Shift+E".spawn = [ "sh" "-c" "${pkgs.wl-clipboard}/bin/wl-paste | ${lib.getExe pkgs.swappy} -f -" ];
            "Mod+Shift+S".spawn = [ "sh" "-c" "${lib.getExe pkgs.grim} -g \"$(${lib.getExe pkgs.slurp} -w 0)\" - | ${pkgs.wl-clipboard}/bin/wl-copy" ];
            "Mod+F".maximize-column = _: {};
            "Mod+Shift+F".fullscreen-window = _: {};
            "Mod+C".center-column = _: {};
 
            "Mod+Left".focus-column-left = _: {};
            "Mod+Right".focus-column-right = _: {};
            "Mod+Up".focus-window-up = _: {};
            "Mod+Down".focus-window-down = _: {};
 
            "Mod+Shift+Left".move-column-left = _: {};
            "Mod+Shift+Right".move-column-right = _: {};
            "Mod+Shift+Up".move-window-up = _: {};
            "Mod+Shift+Down".move-window-down = _: {};
 
            "Mod+WheelScrollDown".focus-column-right = _: {};
            "Mod+WheelScrollUp".focus-column-left = _: {};
 
            "Mod+1".focus-workspace = 1;
            "Mod+2".focus-workspace = 2;
            "Mod+3".focus-workspace = 3;
            "Mod+4".focus-workspace = 4;
            "Mod+5".focus-workspace = 5;
            "Mod+6".focus-workspace = 6;
            "Mod+7".focus-workspace = 7;
            "Mod+8".focus-workspace = 8;
            "Mod+9".focus-workspace = 9;
 
            "Mod+Shift+1".move-column-to-workspace = 1;
            "Mod+Shift+2".move-column-to-workspace = 2;
            "Mod+Shift+3".move-column-to-workspace = 3;
            "Mod+Shift+4".move-column-to-workspace = 4;
            "Mod+Shift+5".move-column-to-workspace = 5;
            "Mod+Shift+6".move-column-to-workspace = 6;
            "Mod+Shift+7".move-column-to-workspace = 7;
            "Mod+Shift+8".move-column-to-workspace = 8;
            "Mod+Shift+9".move-column-to-workspace = 9;
 
            "Mod+Shift+E".quit = _: {};
            "Mod+Shift+P".power-off-monitors = _: {};
          };
        };
      };

      which-key = inputs.wrapper-modules.wrappers.wlr-which-key.wrap {
        inherit pkgs;
        settings = {
          font = "JetBrainsMono Nerd Font 12";
          background = "#282828";
          color = "#ebdbb2";
          border = "#fabd2f";
          separator = " ➜ ";
          border_width = 2;
          corner_r = 15;
          padding = 15;
          rows_per_column = 5;
          column_padding = 25;
          anchor = "bottom-right";
          margin_right = 10;
          margin_bottom = 10;
          menu = [
            { key = "f"; label = "Firefox"; exec = "firefox"; }
            { key = "k"; label = "Kitty"; exec = "kitty"; }
            { key = "y"; label = "Yazi"; exec = "kitty -e yazi"; }
            { key = "b"; label = "Bluetooth Panel"; exec = "noctalia-shell ipc call bluetooth togglePanel"; }
            { key = "w"; label = "WiFi Panel"; exec = "noctalia-shell ipc call wifi togglePanel"; }
            { key = "s"; label = "Volume Control"; exec = "pavucontrol"; }
            { key = "e"; label = "Exit Niri"; exec = "niri msg action quit"; }
          ];
        };
      };
    };
  };
}
