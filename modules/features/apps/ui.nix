# apps/ui.nix — Niri WM + Noctalia shell + GTK + Fonts
{ self, inputs, ... }: {
  flake.nixosModules.ui = { config, pkgs, lib, userName, ... }:
    let
      cfg = config.filosofo.features.desktop.niri;

      # ── GTK theme definitions ─────────────────────────────────────────────
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
      options.filosofo.features.desktop.niri.enable =
        lib.mkEnableOption "Enable the Niri + Noctalia desktop environment";

      config = lib.mkIf cfg.enable {
        # ── Niri window manager ─────────────────────────────────────────────
        programs.niri = {
          enable  = true;
          package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
        };

        # ── Login manager (tuigreet → niri) ─────────────────────────────────
        services.greetd = {
          enable   = true;
          settings.default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri";
            user    = "greeter";
          };
        };

        # ── Bluetooth ───────────────────────────────────────────────────────
        hardware.bluetooth.enable      = true;
        hardware.bluetooth.powerOnBoot = true;

        # ── System packages: Noctalia shell + Niri companions ───────────────
        environment.systemPackages = with pkgs; [
          self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-shell
          self.packages.${pkgs.stdenv.hostPlatform.system}.which-key
          kitty
          awww # Wallpaper daemon
          wayland-utils
          wl-clipboard
          libnotify
          pavucontrol
          brightnessctl
          themePackage
          iconPackage
          adwaita-icon-theme
        ];

        # ── GTK/QT Styling ──────────────────────────────────────────────────
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

        # ── Fastfetch Custom Premium Theme ────────────────────────────────────
        home-manager.users.${userName} = { pkgs, ... }: {
          xdg.configFile."fastfetch/config.jsonc".text = ''
            {
              "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
              "logo": {
                "source": "${./assets/rher.png}",
                "type": "auto",
                "width": 32,
                "height": 15,
                "padding": {
                  "top": 1,
                  "left": 3
                }
              },
              "display": {
                "separator": " ➜  ",
                "color": {
                  "keys": "green",
                  "title": "green"
                }
              },
              "modules": [
                "title",
                {
                  "type": "custom",
                  "format": "┌──────────────────────────────────────────┐",
                  "outputColor": "green"
                },
                {
                  "type": "os",
                  "key": "    OS      ",
                  "keyColor": "green"
                },
                {
                  "type": "kernel",
                  "key": "    Kernel  ",
                  "keyColor": "green"
                },
                {
                  "type": "uptime",
                  "key": "  󰅐  Uptime  ",
                  "keyColor": "green"
                },
                {
                  "type": "packages",
                  "key": "  󰏖  Pkgs    ",
                  "keyColor": "green"
                },
                {
                  "type": "shell",
                  "key": "    Shell   ",
                  "keyColor": "green"
                },
                {
                  "type": "wm",
                  "key": "    WM      ",
                  "keyColor": "yellow"
                },
                {
                  "type": "theme",
                  "key": "  󰉼  Theme   ",
                  "keyColor": "yellow"
                },
                {
                  "type": "terminal",
                  "key": "    Term    ",
                  "keyColor": "yellow"
                },
                {
                  "type": "cpu",
                  "key": "    CPU     ",
                  "keyColor": "blue"
                },
                {
                  "type": "gpu",
                  "key": "  󰘚  GPU     ",
                  "keyColor": "blue"
                },
                {
                  "type": "memory",
                  "key": "    Memory  ",
                  "keyColor": "blue"
                },
                {
                  "type": "custom",
                  "format": "└──────────────────────────────────────────┘",
                  "outputColor": "green"
                },
                "break",
                {
                  "type": "colors",
                  "symbol": "circle"
                }
              ]
            }
          '';
        };

        # ── Audio Stack (Pipewire + Denoising) ──────────────────────────────
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
          jack.enable = true;
          extraConfig = {
            pipewire."99-input-denoising" = {
              "context.modules" = [
                {
                  "name" = "libpipewire-module-filter-chain";
                  "args" = {
                    "node.description" = "DeepFilter Noise Cancelling Source";
                    "media.name" = "DeepFilter Noise Cancelling Source";
                    "filter.graph" = {
                      "nodes" = [
                        {
                          "type" = "ladspa";
                          "name" = "DeepFilter Mono";
                          "plugin" = "${pkgs.deepfilternet}/lib/ladspa/libdeep_filter_ladspa.so";
                          "label" = "deep_filter_mono";
                        }
                      ];
                    };
                    "audio.rate" = 48000;
                    "capture.props" = {
                      "node.name" = "deep_filter_mono_input";
                      "node.passive" = true;
                    };
                    "playback.props" = {
                      "node.name" = "deep_filter_mono_output";
                      "media.class" = "Audio/Source";
                    };
                  };
                }
              ];
            };
          };
        };
        services.pulseaudio.enable = false;

        # ── Fonts ───────────────────────────────────────────────────────────
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

        # ── Required services ───────────────────────────────────────────────
        services.dbus.enable = true;
        services.flatpak.enable = true;
        xdg.portal = {
          enable = true;
          extraPortals = [ pkgs.xdg-desktop-portal-gnome pkgs.xdg-desktop-portal-gtk ];
          config.common.default = "*";
        };
      };
    };

  perSystem = { pkgs, ... }: {
    packages = {
      # Wrapped Noctalia Shell 
      noctalia-shell = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
        inherit pkgs;
        package = pkgs.noctalia-shell.overrideAttrs (old: {
          name = "filosofo-noctalia";
        });
        env = {
          "NOCTALIA_CACHE_DIR" = "/tmp/filosofo-noctalia-cache/";
        };
        colors = {
          mError = "#fb4934";
          mHover = "#83a598";
          mOnError = "#282828";
          mOnHover = "#282828";
          mOnPrimary = "#282828";
          mOnSecondary = "#282828";
          mOnSurface = "#fbf1c7";
          mOnSurfaceVariant = "#ebdbb2";
          mOnTertiary = "#282828";
          mOutline = "#57514e";
          mPrimary = "#b8bb26";
          mSecondary = "#fabd2f";
          mShadow = "#282828";
          mSurface = "#282828";
          mSurfaceVariant = "#3c3836";
          mTertiary = "#83a598";
        };
        settings = {
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
            avatarImage = ./assets/avatar.png;
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

      # Wrapped Niri 
      niri = inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;
        v2-settings = true;
        settings = {
          input = {
            keyboard = {
              xkb = {
                layout = "us";
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
            [ "awww" "img" "${./assets/walls/w10.jpg}" ]
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
            "Mod+D".spawn = [ "noctalia-shell" "app-launcher" "toggle" ];
            "Mod+Shift+Slash".spawn = "which-key";
            "Mod+Q".close-window = _: {};
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

      # Wrapped which-key 
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
            { key = "e"; label = "Exit Niri"; exec = "niri msg action quit"; }
          ];
        };
      };
    };
  };
}
