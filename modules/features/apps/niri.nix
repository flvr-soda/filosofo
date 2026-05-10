{ self, inputs, ... }: {
  # Niri Window Manager — wrapped with nix-wrapper-modules
  perSystem = { pkgs, lib, ... }: {
    packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      v2-settings = true;
      settings = let
        noctaliaExe = lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-shell;
        
        # Helper to generate the wlr-which-key menu executable
        mkWhichKey = menu: lib.getExe (
          inputs.wrapper-modules.wrappers.wlr-which-key.wrap {
            inherit pkgs;
            settings = {
              inherit menu;
              font = "JetBrainsMono Nerd Font 12";
              background = "#${self.themeNoHash.base00}";
              color = "#${self.themeNoHash.base06}";
              border = "#${self.themeNoHash.base0F}";
              separator = " ➜ ";
              border_width = 2;
              corner_r = 15;
              padding = 15;
              rows_per_column = 5;
              column_padding = 25;
              anchor = "bottom-right";
              margin_right = 0;
              margin_bottom = 5;
              margin_left = 5;
              margin_top = 0;
            };
          }
        );

      in {
        prefer-no-csd = _: { };

        input = {
          focus-follows-mouse = _: { };
          keyboard = {
            xkb = {
              layout = "latam";
              options = "caps:escape";
            };
            repeat-rate = 40;
            repeat-delay = 250;
          };
          touchpad = {
            natural-scroll = _: { };
            tap = _: { };
          };
          mouse.accel-profile = "flat";
        };

        binds = {
          # ── Launch ────────────────────────────────────────────
          "Mod+Return".spawn = "alacritty";
          "Mod+Space".spawn-sh = "${noctaliaExe} ipc call launcher toggle";

          # ── Window management ─────────────────────────────────
          "Mod+Q".close-window = _: { };
          "Mod+F".maximize-column = _: { };
          "Mod+G".fullscreen-window = _: { };
          "Mod+Shift+F".toggle-window-floating = _: { };
          "Mod+C".center-column = _: { };

          # ── Focus (vim-style) ─────────────────────────────────
          "Mod+H".focus-column-left = _: { };
          "Mod+L".focus-column-right = _: { };
          "Mod+K".focus-window-up = _: { };
          "Mod+J".focus-window-down = _: { };

          "Mod+Left".focus-column-left = _: { };
          "Mod+Right".focus-column-right = _: { };
          "Mod+Up".focus-window-up = _: { };
          "Mod+Down".focus-window-down = _: { };

          # ── Move windows ──────────────────────────────────────
          "Mod+Shift+H".move-column-left = _: { };
          "Mod+Shift+L".move-column-right = _: { };
          "Mod+Shift+K".move-window-up = _: { };
          "Mod+Shift+J".move-window-down = _: { };

          # ── Resize ────────────────────────────────────────────
          "Mod+Ctrl+H".set-column-width = "-5%";
          "Mod+Ctrl+L".set-column-width = "+5%";
          "Mod+Ctrl+J".set-window-height = "-5%";
          "Mod+Ctrl+K".set-window-height = "+5%";

          # ── Workspaces ────────────────────────────────────────
          "Mod+1".focus-workspace = "w0";
          "Mod+2".focus-workspace = "w1";
          "Mod+3".focus-workspace = "w2";
          "Mod+4".focus-workspace = "w3";
          "Mod+5".focus-workspace = "w4";
          "Mod+6".focus-workspace = "w5";
          "Mod+7".focus-workspace = "w6";
          "Mod+8".focus-workspace = "w7";
          "Mod+9".focus-workspace = "w8";
          "Mod+0".focus-workspace = "w9";

          "Mod+Shift+1".move-column-to-workspace = "w0";
          "Mod+Shift+2".move-column-to-workspace = "w1";
          "Mod+Shift+3".move-column-to-workspace = "w2";
          "Mod+Shift+4".move-column-to-workspace = "w3";
          "Mod+Shift+5".move-column-to-workspace = "w4";
          "Mod+Shift+6".move-column-to-workspace = "w5";
          "Mod+Shift+7".move-column-to-workspace = "w6";
          "Mod+Shift+8".move-column-to-workspace = "w7";
          "Mod+Shift+9".move-column-to-workspace = "w8";
          "Mod+Shift+0".move-column-to-workspace = "w9";

          # ── Scroll-wheel workspace switching ──────────────────
          "Mod+WheelScrollDown".focus-column-left = _: { };
          "Mod+WheelScrollUp".focus-column-right = _: { };
          "Mod+Ctrl+WheelScrollDown".focus-workspace-down = _: { };
          "Mod+Ctrl+WheelScrollUp".focus-workspace-up = _: { };

          # ── Noctalia panels & Which-Key Menu ──────────────────
          "Mod+B".spawn-sh = "${noctaliaExe} ipc call bluetooth togglePanel";
          "Mod+N".spawn-sh = "${noctaliaExe} ipc call notificationHistory togglePanel";
          "Mod+D".spawn-sh = mkWhichKey [
            {
              key = "b";
              desc = "Bluetooth";
              cmd = "${noctaliaExe} ipc call bluetooth togglePanel";
            }
            {
              key = "w";
              desc = "Wifi";
              cmd = "${noctaliaExe} ipc call wifi togglePanel";
            }
            {
              key = "f";
              desc = "Firefox";
              cmd = "firefox";
            }
            {
              key = "v";
              desc = "VSCode";
              cmd = "code";
            }
            {
              key = "s";
              desc = "Pavucontrol";
              cmd = "${lib.getExe pkgs.pavucontrol}";
            }
          ];

          # ── Audio ─────────────────────────────────────────────
          "XF86AudioRaiseVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioLowerVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-";
          "XF86AudioMute".spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "Mod+V".spawn-sh = "${pkgs.alsa-utils}/bin/amixer sset Capture toggle";

          # ── Brightness ────────────────────────────────────────
          "XF86MonBrightnessUp".spawn-sh = "brightnessctl s +5%";
          "XF86MonBrightnessDown".spawn-sh = "brightnessctl s 5%-";

          # ── Screenshots ───────────────────────────────────────
          "Mod+Ctrl+S".spawn-sh = "${lib.getExe pkgs.grim} -l 0 - | ${pkgs.wl-clipboard}/bin/wl-copy";
          "Mod+Shift+S".spawn-sh = lib.getExe (pkgs.writeShellApplication {
            name = "screenshot-area";
            text = ''
              ${lib.getExe pkgs.grim} -g "$(${lib.getExe pkgs.slurp} -w 0)" - \
              | ${pkgs.wl-clipboard}/bin/wl-copy
            '';
          });
        };

        layout = {
          gaps = 8;
          focus-ring = {
            width = 2;
            active-color = self.theme.base0B;
          };
        };

        workspaces = let
          ws = { layout.gaps = 8; };
        in {
          "w0" = ws; "w1" = ws; "w2" = ws; "w3" = ws; "w4" = ws;
          "w5" = ws; "w6" = ws; "w7" = ws; "w8" = ws; "w9" = ws;
        };

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

        spawn-at-startup = [
          noctaliaExe
          (lib.getExe (
            pkgs.writeShellScriptBin "wallpaper"
            "${lib.getExe pkgs.swaybg} -i ${./assets/wallpaper.jpg} -m fill"
          ))
        ];
      };
    };
  };

  flake.nixosModules.niri = { pkgs, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
    };

    # Wayland session dependencies
    environment.systemPackages = with pkgs; [
      alacritty
      swaybg
      wl-clipboard
      grim
      slurp
      pavucontrol
      brightnessctl
      xwayland-satellite
    ];
  };
}
