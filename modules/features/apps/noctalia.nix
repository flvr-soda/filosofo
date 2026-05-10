{ self, inputs, ... }: {
  # Noctalia Shell — wrapped with nix-wrapper-modules
  perSystem = { pkgs, ... }: {
    packages.noctalia-shell = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      env = {
        "NOCTALIA_CACHE_DIR" = "/tmp/filosofo-noctalia-cache/";
      };
      # Gruvbox Material Dark — sourced from centralized theme.nix
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
          sortByMostUsed = true;
          terminalCommand = "alacritty -e";
          viewMode = "list";
        };
        audio = {
          externalMixer = "pavucontrol";
          volumeStep = 5;
        };
        bar = {
          density = "comfortable";
          exclusive = true;
          position = "left";
          widgets = {
            center = [ ];
            left = [
              {
                colorizeDistroLogo = true;
                enableColorization = true;
                id = "ControlCenter";
                useDistroLogo = true;
              }
              {
                enableScrollWheel = true;
                hideUnoccupied = true;
                id = "Workspace";
                labelMode = "none";
              }
            ];
            right = [
              { id = "NotificationHistory"; showUnreadBadge = true; }
              { displayMode = "alwaysHide"; id = "Volume"; }
              {
                displayMode = "alwaysShow";
                hideIfNotDetected = true;
                id = "Battery";
                warningThreshold = 20;
              }
              {
                formatHorizontal = "HH:mm ddd, MMM dd";
                formatVertical = "HH mm - dd MM";
                id = "Clock";
                usePrimaryColor = true;
              }
              { id = "Tray"; }
            ];
          };
        };
        controlCenter = {
          cards = [
            { enabled = true; id = "profile-card"; }
            { enabled = true; id = "shortcuts-card"; }
            { enabled = true; id = "audio-card"; }
            { enabled = true; id = "brightness-card"; }
            { enabled = true; id = "media-sysmon-card"; }
          ];
          position = "close_to_bar_button";
          shortcuts = {
            left = [
              { id = "WiFi"; }
              { id = "Bluetooth"; }
              { id = "ScreenRecorder"; }
            ];
            right = [
              { id = "Notifications"; }
              { id = "PowerProfile"; }
            ];
          };
        };
        general = {
          avatarImage = ./assets/avatar.png;
          enableShadows = true;
          lockOnSuspend = true;
          radiusRatio = 1;
          showSessionButtonsOnLockScreen = true;
        };
        notifications = {
          enabled = true;
          location = "top_right";
          normalUrgencyDuration = 8;
        };
        osd = {
          enabled = true;
          location = "bottom";
        };
        sessionMenu = {
          countdownDuration = 10000;
          enableCountdown = true;
          position = "center";
        };
        settingsVersion = 32;
        wallpaper.enabled = false; # We use swaybg externally
      };
    };
  };

  flake.nixosModules.noctalia = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-shell
    ];
  };
}
