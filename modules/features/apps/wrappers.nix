{ inputs, self, ... }: {
  # Niri Wrapper Module — Approach from nixconf
  flake.wrappersModules.niri = { config, lib, pkgs, ... }: {
    options.terminal = lib.mkOption {
      type = lib.types.str;
      default = "alacritty";
    };
    config = {
      v2-settings = true;
      settings = let
        noctaliaExe = lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-shell;
      in {
        prefer-no-csd = _: { };

        input = {
          focus-follows-mouse = _: { };
          keyboard = {
            xkb = {
              layout = "latam";
            };
          };

          touchpad = {
            natural-scroll = _: { };
            tap = _: { };
          };
          mouse = {
            accel-profile = "flat";
          };
        };

        binds = {
          "Mod+Return".spawn = config.terminal;

          "Mod+Q".close-window = _: { };
          "Mod+F".maximize-column = _: { };
          "Mod+G".fullscreen-window = _: { };
          "Mod+Shift+F".toggle-window-floating = _: { };
          "Mod+C".center-column = _: { };

          "Mod+H".focus-column-left = _: { };
          "Mod+L".focus-column-right = _: { };
          "Mod+K".focus-window-up = _: { };
          "Mod+J".focus-window-down = _: { };

          "Mod+Left".focus-column-left = _: { };
          "Mod+Right".focus-column-right = _: { };
          "Mod+Up".focus-window-up = _: { };
          "Mod+Down".focus-window-down = _: { };

          "Mod+WheelScrollDown".focus-column-left = _: { };
          "Mod+WheelScrollUp".focus-column-right = _: { };
          "Mod+Ctrl+WheelScrollDown".focus-workspace-down = _: { };
          "Mod+Ctrl+WheelScrollUp".focus-workspace-up = _: { };

          "Mod+Shift+H".move-column-left = _: { };
          "Mod+Shift+L".move-column-right = _: { };
          "Mod+Shift+K".move-window-up = _: { };
          "Mod+Shift+J".move-window-down = _: { };

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

          "Mod+Space".spawn-sh = "${noctaliaExe} ipc call launcher toggle";

          "Mod+V".spawn-sh = ''${pkgs.alsa-utils}/bin/amixer sset Capture toggle'';

          "XF86AudioRaiseVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioLowerVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-";
          "XF86AudioMute".spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";

          "Mod+Ctrl+H".set-column-width = "-5%";
          "Mod+Ctrl+L".set-column-width = "+5%";
          "Mod+Ctrl+J".set-window-height = "-5%";
          "Mod+Ctrl+K".set-window-height = "+5%";

          "Mod+Ctrl+S".spawn-sh = ''${lib.getExe pkgs.grim} -l 0 - | ${pkgs.wl-clipboard}/bin/wl-copy'';
          "Mod+Shift+S".spawn-sh = ''${lib.getExe pkgs.grim} -g "$(${lib.getExe pkgs.slurp} -w 0)" - | ${pkgs.wl-clipboard}/bin/wl-copy'';
          
          "Mod+B".spawn-sh = "${noctaliaExe} ipc call bluetooth togglePanel";
          "Mod+N".spawn-sh = "${noctaliaExe} ipc call notificationHistory togglePanel";
        };

        layout = {
          gaps = 8;
          focus-ring = {
            width = 2;
            active-color = "#${self.themeNoHash.base0B}";
          };
        };

        workspaces = let
          settings = { layout.gaps = 8; };
        in {
          "w0" = settings; "w1" = settings; "w2" = settings; "w3" = settings; "w4" = settings;
          "w5" = settings; "w6" = settings; "w7" = settings; "w8" = settings; "w9" = settings;
        };

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

        spawn-at-startup = [
          noctaliaExe
          "${pkgs.awww}/bin/awww-daemon"
          "${lib.getExe pkgs.awww} img ${self.wallpaper}"
        ];
      };
    };
  };

  perSystem = { pkgs, ... }: {
    packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      v2-settings = true;
      imports = [ self.wrappersModules.niri ];
    };


    packages.noctalia-shell = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      env = { "NOCTALIA_CACHE_DIR" = "/tmp/noctalia-cache/"; };
      colors = {
        mError = self.theme.base08;
        mHover = self.theme.base0D;
        mOnError = self.theme.base00;
        mOnHover = self.theme.base00;
        mOnPrimary = self.theme.base00;
        mOnSecondary = self.theme.base00;
        mOnSurface = self.theme.base07;
        mOnSurfaceVariant = self.theme.base06;
        mOnTertiary = self.theme.base00;
        mOutline = self.theme.base02;
        mPrimary = self.theme.base0B;
        mSecondary = self.theme.base0A;
        mShadow = self.theme.base00;
        mSurface = self.theme.base00;
        mSurfaceVariant = self.theme.base01;
        mTertiary = self.theme.base0D;
      };
      settings = {
        appLauncher = {
          iconMode = "tabler";
          position = "center";
          showCategories = true;
          terminalCommand = "alacritty -e";
          viewMode = "list";
        };
        audio = {
          externalMixer = "pavucontrol";
          volumeStep = 5;
        };
        brightness = {
          brightnessStep = 5;
          enableDdcSupport = false;
          enforceMinimum = true;
        };
        bar = {
          density = "comfortable";
          exclusive = true;
          position = "left";
          widgets = {
            left = [
              {
                id = "ControlCenter";
                useDistroLogo = true;
                colorizeDistroLogo = true;
                colorizeSystemIcon = "tertiary";
                enableColorization = true;
              }
              {
                id = "Workspace";
                characterCount = 2;
                colorizeIcons = false;
                enableScrollWheel = true;
                followFocusedScreen = false;
                hideUnoccupied = true;
                labelMode = "none";
                showApplications = false;
                showLabelsOnlyWhenOccupied = true;
              }
            ];
            right = [
              {
                id = "NotificationHistory";
                hideWhenZero = false;
                showUnreadBadge = true;
              }
              { id = "PowerProfile"; }
              {
                id = "Volume";
                displayMode = "alwaysHide";
              }
              {
                id = "Battery";
                deviceNativePath = "";
                displayMode = "alwaysShow";
                hideIfNotDetected = true;
                showNoctaliaPerformance = false;
                showPowerProfiles = false;
                warningThreshold = 20;
              }
              {
                id = "Microphone";
                displayMode = "alwaysHide";
              }
              {
                id = "KeyboardLayout";
                displayMode = "forceOpen";
              }
              {
                id = "Clock";
                usePrimaryColor = true;
                formatHorizontal = "HH:mm ddd, MMM dd";
                formatVertical = "HH mm - dd MM";
              }
              {
                id = "Tray";
                drawerEnabled = true;
                colorizeIcons = false;
                hidePassive = false;
              }
            ];
          };
        };
        controlCenter = {
          position = "close_to_bar_button";
          cards = [
            { id = "profile-card"; }
            { id = "shortcuts-card"; }
            { id = "audio-card"; }
            { id = "brightness-card"; }
            { id = "media-sysmon-card"; }
          ];
          shortcuts = {
            left = [ { id = "WiFi"; } { id = "Bluetooth"; } ];
            right = [ { id = "Notifications"; } { id = "PowerProfile"; } ];
          };
        };
        general = {
          avatarImage = ./assets/avatar.png;
          radiusRatio = 1;
          enableShadows = true;
          lockOnSuspend = true;
        };
        notifications = {
          enabled = true;
          location = "top_right";
        };
        osd = {
          enabled = true;
          location = "bottom";
        };
        sessionMenu = {
          position = "center";
          enableCountdown = true;
        };
        settingsVersion = 32;
        wallpaper.enabled = false;
        templates = {
          niri = false;
        };
      };
    };
  };
}
