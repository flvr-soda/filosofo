# apps/ui/noctalia.nix — Noctalia shell wrapper configuration
{ self, inputs, ... }: {
  flake.nixosModules.ui-noctalia = { config, pkgs, lib, ... }:
    let
      cfg = config.filosofo.features.desktop.niri;
    in
    {
      config = lib.mkIf cfg.enable {
        environment.systemPackages = [
          self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-shell
        ];
      };
    };

  perSystem = { pkgs, ... }: {
    packages = {
      noctalia-shell = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
        inherit pkgs;
        package = pkgs.noctalia-shell.overrideAttrs (old: {
          name = "filosofo-noctalia";
        });
        env = {
          "NOCTALIA_CACHE_DIR" = "$HOME/.cache/noctalia/";
        };
        settings = {
          wallpaper = {
            directory = ./../assets/walls;
            enableColors = true;
            interval = 30;
            random = true;
          };
          theme = {
            source = "wallpaper";  # or "builtin", "community", "custom"
            wallpaperAlgorithm = "m3-tonal-spot";  # algorithm for color extraction
            # Other options: "m3-content", "m3-fruit-salad", "vibrant", "faithful", "muted"
            darkMode = "dark";  # or "auto", "light"
          };
          templates = {
            enabled = true;
            builtins = [ "kitty" "code"];
          };
          appLauncher = {
            customLaunchPrefix = "";
            customLaunchPrefixEnabled = false;
            enableClipPreview = true;
            enableClipboardHistory = false;
            iconMode = "tabler";
            pinnedExecs = [];
            position = "center";
            showCategories = true;
            sortByMostUsed = true;
            terminalCommand = "kitty -e";
            useApp2Unit = false;
            viewMode = "list";
          };

          dock = {
            enabled = true;
            position = "bottom";       
            displayMode = "auto_hide";  
            dockType = "floating";     
            pinnedApps = [
              "firefox.desktop"
              "steam.desktop"
              "vscodium.desktop"
              "kitty.desktop"
              "org.gnome.Nautilus.desktop"
            ];
            pinnedStatic = true;
            groupApps = true;
            showLauncherIcon = true;
            launcherPosition = "start";
          };

          audio = {
            cavaFrameRate = 30;
            externalMixer = "pavucontrol";
            visualizerType = "linear";
            volumeStep = 5;
          };
          bar = {
            capsuleOpacity = 1;
            density = "comfortable";
            exclusive = true;
            floating = false;
            marginHorizontal = 0.25;
            marginVertical = 0.25;
            monitors = [];
            outerCorners = true;
            position = "left";
            showCapsule = false;
            showOutline = false;
            transparent = false;
            widgets = {
              center = [];
              left = [
                {
                  colorizeDistroLogo = true;
                  colorizeSystemIcon = "tertiary";
                  enableColorization = true;
                  id = "ControlCenter";
                  useDistroLogo = true;
                }
                {
                  characterCount = 2;
                  colorizeIcons = false;
                  enableScrollWheel = true;
                  hideUnoccupied = true;
                  id = "Workspace";
                  labelMode = "none";
                  showApplications = false;
                  showLabelsOnlyWhenOccupied = true;
                }
              ];
              right = [
                {
                  hideWhenZero = false;
                  id = "NotificationHistory";
                  showUnreadBadge = true;
                }
                { id = "PowerProfile"; }
                {
                  displayMode = "alwaysHide";
                  id = "Volume";
                }
                {
                  displayMode = "alwaysShow";
                  hideIfNotDetected = true;
                  id = "Battery";
                  warningThreshold = 20;
                }
                {
                  displayMode = "alwaysHide";
                  id = "Microphone";
                }
                {
                  displayMode = "forceOpen";
                  id = "KeyboardLayout";
                }
                {
                  formatHorizontal = "HH:mm ddd, MMM dd";
                  formatVertical = "HH mm - dd MM";
                  id = "Clock";
                  usePrimaryColor = true;
                }
                {
                  blacklist = [];
                  colorizeIcons = false;
                  drawerEnabled = true;
                  hidePassive = false;
                  id = "Tray";
                  pinned = [];
                }
              ];
            };
          };
          general = {
            allowPanelsOnScreenWithoutBar = true;
            animationDisabled = false;
            animationSpeed = 1;
            avatarImage = ./../assets/avatar.png;
            boxRadiusRatio = 1;
            compactLockScreen = false;
            dimmerOpacity = 0.15;
            enableShadows = true;
            forceBlackScreenCorners = false;
            iRadiusRatio = 1;
            lockOnSuspend = true;
            radiusRatio = 1;
            scaleRatio = 1;
            screenRadiusRatio = 1;
            shadowDirection = "bottom_right";
            shadowOffsetX = 2;
            shadowOffsetY = 3;
            showHibernateOnLockScreen = false;
            showScreenCorners = false;
            showSessionButtonsOnLockScreen = true;
          };
          notifications = {
            backgroundOpacity = 1;
            criticalUrgencyDuration = 15;
            enableKeyboardLayoutToast = true;
            enabled = true;
            location = "top_right";
            lowUrgencyDuration = 8;
            monitors = [];
            normalUrgencyDuration = 8;
            overlayLayer = true;
            respectExpireTimeout = false;
            sounds = {
              enabled = false;
              excludedApps = "discord,firefox,chrome,chromium,edge";
              volume = 0.5;
            };
          };
          osd = {
            autoHideMs = 3000;
            backgroundOpacity = 1;
            enabled = true;
            enabledTypes = [ 0 1 2 4 ];
            location = "bottom";
            monitors = [];
            overlayLayer = true;
          };
          sessionMenu = {
            countdownDuration = 10000;
            enableCountdown = true;
            largeButtonsStyle = false;
            position = "center";
            powerOptions = [
              { action = "lock"; enabled = true; }
              { action = "suspend"; enabled = true; }
              { action = "hibernate"; enabled = true; }
              { action = "reboot"; enabled = true; }
              { action = "logout"; enabled = true; }
              { action = "shutdown"; enabled = true; }
            ];
            showHeader = true;
          };
          settingsVersion = 32;
          ui = {
            fontDefault = "Ubuntu Sans";
            fontDefaultScale = 1;
            fontFixed = "JetBrainsMono Nerd Font";
            fontFixedScale = 1;
            panelBackgroundOpacity = 1;
            panelsAttachedToBar = true;
            settingsPanelMode = "attached";
            tooltipsEnabled = true;
          };
       };
      };
    };
  };
}
