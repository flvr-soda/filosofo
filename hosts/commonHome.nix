{
  pkgs,
  inputs,
  lib,
  username,
  gitUsername,
  gitEmail,
  isDesktop,
  config,
  ...
}: let
  wallpaperDir = "${config.home.homeDirectory}/pictures/wallpapers";
  logoDir = "${config.home.homeDirectory}/pictures/logos";
  waybarConfigDir = "${config.home.homeDirectory}/.config/waybar";
in {
  nixpkgs.config.allowUnfree = true;

  home = {
    # Paths and users home manager should manage
    username = "${username}";
    homeDirectory = "/home/${username}";
    stateVersion = "25.05"; # Do not change this

    packages = with pkgs; [
      # Applications for general use and productivity
      obsidian
      qbittorrent-enhanced
      vlc
      texstudio
      komikku
      wpsoffice
      miktex
      kew
      kiwix
      imagemagick
      pywal

      # Terminal-based tools and utilities
      cool-retro-term # A cool retro terminal emulator
      fastfetch # Modern system info tool
      tree
      cava # Command-line audio visualizer
      cmatrix # The Matrix effect in your terminal
      btop # Advanced process monitoring
      yazi # TUI file manager
      eza
      bat
      ripgrep
      ffmpeg # Essential multimedia converter

      # Wayland-specific desktop tools
      dunst # Notification daemon
      swww # Wallpaper utility
      clipse # Clipboard manager (ensure this is a Wayland-compatible one if needed)
      grim
      grimblast # Screenshot utility for Wayland
      slurp
      swaylock
      wl-clipboard

      # Compression/Archive tools
      p7zip
      unrar

      # Windows compatibility and gaming tools
      wine
      protonup
      winetricks
    ];

    # STYLIX configuration (commented out for now)
    /*
    stylix = {
      enable = true;
      polarity = "dark";
      targets.firefox.profileNames = ["${username}"];
      targets.qt.enable = true;
      targets.gtk.enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-soft.yaml";
    };
    */
  };
  qt = {
    enable = true;
  };

  gtk = {
    enable = true;
  };

  wayland.windowManager.hyprland = lib.mkIf isDesktop {
    enable = true;
    xwayland.enable = true;
    systemd.variables = ["--all"];
    settings = {
      exec-once = [
        "swww init"
        "dunst"
        "udiskie"
        "waybar"
        "nm-applet"
      ];

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        layout = "dwindle";
      };

      decoration = {
        blur = {
          enabled = true;
          size = 8;
          passes = 2;
          vibrancy = 0.1696;
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "default, 0.12, 0.92, 0.08, 1.0"
          "wind, 0.12, 0.92, 0.08, 1.0"
          "overshot, 0.18, 0.95, 0.22, 1.03"
          "liner, 1, 1, 1, 1"
        ];
        animation = [
          "windows, 1, 5, wind, popin 60%"
          "windowsIn, 1, 6, overshot, popin 60%"
          "windowsOut, 1, 4, overshot, popin 60%"
          "windowsMove, 1, 4, overshot, slide"
          "layers, 1, 4, default, popin"
          "fadeIn, 1, 7, default"
          "fadeOut, 1, 7, default"
          "fadeSwitch, 1, 7, default"
          "fadeShadow, 1, 7, default"
          "fadeDim, 1, 7, default"
          "fadeLayers, 1, 7, default"
          "workspaces, 1, 5, overshot, slidevert"
          "border, 1, 1, liner"
          "borderangle, 1, 24, liner, loop"
        ];
      };

      "$mod" = "SUPER";

      bind =
        [
          "$mod, B, exec, firefox"
          "$mod, return, exec, kitty"
          "$mod, C, exec, code"
          "$mod, A, exec, rofi -show drun"
          "$mod, L, exec, swaylock"

          "$mod SHIFT, B, exec, kitty -e btop"
          "$mod, K, exec, kitty -e kew"
          "$mod, E, exec, kitty -e yazi"

          "$mod, Q, killactive"
          "$mod SHIFT, F, togglefloating"
          "$mod, F, fullscreen"
          "$mod, M, exit,"

          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"

          "$mod SHIFT, h, movewindow, l"
          "$mod SHIFT, l, movewindow, r"
          "$mod SHIFT, k, movewindow, u"
          "$mod SHIFT, j, movewindow, d"

          # Screenshots
          ", Print, exec, grimblast copy screen"
          "$mod, Print, exec, grimblast copy area"

          # Scroll through workspaces with mouse wheel
          "$mod, mouse_down, workspace, e+1" # Next workspace
          "$mod, mouse_up, workspace, e-1" # Previous workspace
        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
          builtins.concatLists (builtins.genList (
              i: let
                ws = i + 1;
              in [
                "$mod, code:1${toString i}, workspace, ${toString ws}"
                "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
              ]
            )
            9)
        );

      bindm = [
        # mouse movements
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
        "$mod ALT, mouse:272, resizewindow"
      ];

      input = {
        kb_layout = "es,us"; # US and Spanish layouts
        kb_variant = ",";
        kb_options = "grp:alt_shift_toggle"; # Toggle layouts with Alt+Shift
      };
    };
  };

  programs = {
    pywal.enable = true;

    rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
    };

    swaylock = {
      enable = true;
      settings = {
        daemonize = true;
        show-failed-attempts = true;
        clock = true;
        screenshot = true;
        "effect-blur" = "15x15"; # Strings for effect values
        "effect-vignette" = "1:1"; # Strings for effect values
        color = "1f1d2e80";
        font = "Inter";
        indicator = true;
        "indicator-radius" = 200;
        "indicator-thickness" = 20;
        "line-color" = "1f1d2e";
        "ring-color" = "191724";
        "inside-color" = "1f1d2e";
        "key-hl-color" = "eb6f92";
        "separator-color" = "00000000";
        "text-color" = "e0def4";
        "text-caps-lock-color" = ""; # Empty string
        "line-ver-color" = "eb6f92";
        "ring-ver-color" = "eb6f92";
        "inside-ver-color" = "1f1d2e";
        "text-ver-color" = "e0def4";
        "ring-wrong-color" = "31748f";
        "text-wrong-color" = "31748f";
        "inside-wrong-color" = "1f1d2e";
        "inside-clear-color" = "1f1d2e";
        "text-clear-color" = "e0def4";
        "ring-clear-color" = "9ccfd8";
        "line-clear-color" = "1f1d2e";
        "line-wrong-color" = "1f1d2e";
        "bs-hl-color" = "31748f";
        grace = 2;
        "grace-no-mouse" = true;
        "grace-no-touch" = true;
        datestr = "%a, %B %e";
        timestr = "%I:%M %p";
        "fade-in" = 0.3; # Numbers for float values
        "ignore-empty-password" = true;
      };
    };

    fish = {
      enable = true;
      shellAliases = {
        l = "eza -lh --icons=auto"; # long list
        ls = "eza -1 --icons=auto"; # short list
        ll = "eza -lha --icons=auto --sort=name --group-directories-first"; # long list all
        ld = "eza -lhD --icons=auto"; # long list dirs
        lt = "eza --icons=auto --tree"; # list folder as tree
        vc = "code";
      };
    };

    kitty = {
      enable = true;
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 10;
      };
      settings = {
        background_opacity = 0.8;
      };
    };

    waybar = lib.mkIf isDesktop {
      enable = true;
      settings = {
        configFile = "${waybarConfigDir}/config.jsonc";
        styleFile = "${waybarConfigDir}/style.css";
      };
    };

    starship = {
      enable = true;
      enableBashIntegration = true; # Ensures Starship is initialized in Bash
      enableZshIntegration = true; # Ensures Starship is initialized in Zsh
      enableNushellIntegration = false; # Set to true if you use Nushell
      enableFishIntegration = true; # Set to true if you use Fish

      settings = {
        # The main prompt format defines the order of modules and colors.
        format = "$all";

        # Define the overall prompt character styling
        character = {
          success_symbol = "[>](bold green)";
          error_symbol = "[>](bold red)";
        };

        # Show the current directory
        directory = {
          format = "[ $path](bold blue)";
          truncation_symbol = "…/";
        };

        # Git branch and status
        git_branch = {
          symbol = " ";
          format = "[$symbol$branch](bold purple) ";
        };

        git_status = {
          format = "([$all_status$stashed](purple))";
          # Configure icons for different states
          stashed = "$";
          staged = "+";
          deleted = "✘";
          renamed = "»";
          modified = "!";
          untracked = "?";
        };

        # Host module (useful for SSH sessions)
        hostname = {
          ssh_only = false;
          format = "[@$hostname](bold cyan) ";
        };

        # Display current username (optional, useful for root/sudo sessions)
        username = {
          style_user = "bold yellow";
          show_always = false; # Only show if not standard user
        };

        # Time taken for the last command
        cmd_duration = {
          format = "[$duration](italic white) ";
        };

        # Nix environment detection
        nix_shell = {
          format = "([Nix: $name](bold blue))";
        };

        rust = {symbol = "🦀 ";};
        python = {symbol = "🐍 ";};
      };
    };

    git = {
      enable = true;
      userName = "${gitUsername}";
      userEmail = "${gitEmail}";
      lfs.enable = true;
    };

    neovim = {
      enable = true;
    };

    firefox = {
      enable = true;
      profiles.${username} = {
        settings = {
          "dom.security.https_only_mode" = true;
          "browser.download.panel.shown" = true;
          "identity.fxaccounts.enabled" = false;
          "signon.rememberSignons" = false;
        };
        userChrome = ''
          /* some css */
        '';
        extensions.packages = with inputs.firefox-addons.packages."x86_64-linux"; [
          ublock-origin
          privacy-badger
        ];
      };
    };

    fastfetch = {
      enable = true;
    };

    vscode = {
      enable = true;
      package = pkgs.vscode;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        yzhang.markdown-all-in-one
        jnoortheen.nix-ide
        eamodio.gitlens
        kamadorueda.alejandra
        ms-python.python
        ms-vscode.cpptools
        ms-azuretools.vscode-docker
        ms-vscode-remote.remote-ssh
      ];
      profiles.default.userSettings = {
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "security.workspace.trust.banner" = "never";
      };
    };
  };

  environment = {
    home.file.".config/waybar/config.jsonc" = {
      text = ''
        {
            "margin": "5 20 0 20",
            "modules-left": ["custom/updates", "custom/spotify", "custom/cava"],
            "modules-center": ["clock"],
            "modules-right": ["network", "pulseaudio", "backlight", "battery", "tray"],

            //***************************
            //*  Modules configuration  *
            //***************************

            "custom/updates": {
                "format": "   ",
                "interval": 7200,
                "on-click": "dolphin",
                "signal": 8
            },

            "custom/spotify": {
                "format": "  {}",
                "interval": 5,
                "on-click": "flatpak run com.spotify.Client",
                "exec": "~/.config/waybar/scripts/spotify.sh"
            },

            "clock": {
                "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
                "format": "{:%a | %d %b | %I:%M %p}"
            },

            "custom/cava": {
                "format": "{}",
                "exec": "~/.config/waybar/scripts/cava.sh"
            },

            "network": {
                "format-wifi": "󰤨  {essid} ({signalStrength}%)",
                "format-ethernet": "󰈁 Ethernet",
                "format-disconnected": "󰤭 Disconnected",
                "on-click": "/home/lostfromlight/.config/waybar/scripts/nmtui.sh"
            },

            "pulseaudio": {
                "reverse-scrolling": 1,
                "format": "{volume}% {icon}",
                "format-bluetooth": "{volume}% {icon}",
                "format-muted": " {format_source}",
                "format-source-muted": "Mute 🚫",
                "format-icons": {
                    "headphone": "",
                    "default": ["🕨", "🕩", "🕪"]
                },
                "on-click": "pavucontrol",
                "min-length": 13
            },

            "backlight": {
                "device": "intel_backlight",
                "format": "{percent}% {icon}",
                "format-icons": ["🌑", "🌒", "🌓", "🌔", "🌕"],
                "min-length": 5
            },

            "battery": {
                "states": {
                    "warning": 30,
                    "critical": 15
                },
                "format": " {capacity}% {icon} ",
                "format-charging": "{capacity}% ",
                "format-plugged": "{capacity}% ",
                "format-alt": "{time} {icon}",
                "format-icons": ["▁", "▂", "▃", "▄", "▅"]
            },

            "tray": {
                "icon-size": 16,
                "spacing": 4
            }
        }
      '';
    };

    home.file.".config/waybar/style.css" = {
      text = ''
        * {
            border: none;
            border-radius: 0;
            font-family: JetBrainsMono Nerd Font, monospace;
            font-size: 14px;
            min-height: 0px;
        }

        window#waybar {
            background: transparent;
        }

        window#waybar.hidden {
            opacity: 0.2;
        }

        #custom-updates {
            padding-left: 10px;
            padding-right: 10px;
            border-radius: 5px 20px 5px 20px;
            border: solid 3px;
            border-color: #484a4a;
            transition: background 0.3s ease,
        	border-radius 0.3s ease;
            color: #ffffff;
            background: #0f1c17;
        }

        #custom-updates:hover {
        	border-radius: 20px 5px 20px 5px;
        	background: #484a4a;
        }

        #custom-spotify {
        	margin-left: 8px;
        	padding-left: 10px;
            padding-right: 10px;
            border-radius: 5px 20px 5px 20px;
            border: solid 3px;
            border-color: #484a4a;
            transition: background 0.3s ease-in-out,
        	border-radius 0.3s ease-in-out;
            color: #ffffff;
            background: #0f1c17;
        }

        #custom-spotify:hover {
        	border-radius: 20px 5px 20px 5px;
        	background: #484a4a;
        }


        #clock {
            padding-left: 16px;
            padding-right: 16px;
            border-radius: 5px 5px 20px 20px;
            border: solid 3px;
            border-color: #484a4a;
            transition: background 0.3s ease,
        	border-radius 0.3s ease;
            color: #ffffff;
            background: #0f1c17;
        }

        #clock:hover {
        	border-radius: 20px 20px 5px 5px;
        	background: #484a4a;
        }

        #custom-cava {
        	margin-left: 8px;
        }

        #network {
        	margin-right: 8px;
        	padding-right: 15px;
        	padding-left: 15px;
        	border-radius: 20px 5px 20px 5px;
            border: solid 3px;
            border-color: #484a4a;
            transition: background 0.3s ease,
        	border-radius 0.3s ease;
            color: #ffffff;
            background: #0f1c17;
        }


        #network:hover {
        	border-radius: 5px 20px 5px 20px;
        	background: #484a4a;
        }

        #pulseaudio {
            margin-right: 8px;
            border-radius: 20px 5px 20px 5px;
            padding-left: 0px;
            padding-right: 0px;
            border: solid 3px;
            border-color: #484a4a;
            transition: background 0.3s ease,
        	border-radius 0.3s ease;
            color: #ffffff;
            background: #0f1c17;
        }

        #pulseaudio:hover {
        	border-radius: 5px 20px 5px 20px;
        	background: #484a4a;
        }

        #backlight {
            margin-right: 8px;
            padding-left: 10px;
            padding-right: 10px;
            border-radius: 20px 5px 20px 5px;
            border: solid 3px;
            border-color: #484a4a;
            transition: background 0.3s ease,
        	border-radius 0.3s ease;
            color: #ffffff;
            background: #0f1c17;
        }

        #backlight:hover {
        	border-radius: 5px 20px 5px 20px;
        	background: #484a4a;
        }


        #battery {
            margin-right: 8px;
            padding-left: 1px;
            padding-right: 1px;
            border-radius: 20px 5px 20px 5px;
            border: solid 3px;
            border-color: #484a4a;
            transition: background 0.3s ease,
        	border-radius 0.3s ease;
            color: #ffffff;
            background: #0f1c17;
        }

        #battery:hover {
        	border-radius: 5px 20px 5px 20px;
        	background: #484a4a;
        }


        #battery.charging {
            color: #ffffff;
        	padding-right: 9px;
        	padding-left: 9px;
            /*background-color: #26A65B;*/
            background-color: #0f1c17;
            border: solid 3px;
            border-color: #484a4a;
        }

        #battery.warning:not(.charging) {
            background-color: #0f1c17;
            color: #ff0000;
            border-color: #ff0000;
        }

        #battery.critical:not(.charging) {
            background-color: #0f1c17;
            color: #ffffff;
            border-color: #ad2626;
            animation-name: blink;
            animation-duration: 0.5s;
            animation-timing-function: linear;
            animation-iteration-count: infinite;
            animation-direction: alternate;
        }

        #tooltip {
            background-color: #181818;
        }

        #tray {
            padding-left: 16px;
            padding-right: 16px;
        	margin-right: 8px;
            border-radius: 20px 10px 10px 5px;
            border: solid 3px;
            border-color: #484a4a;
            transition: background 0.3s ease,
        	border-radius 0.3s ease;
            color: #ffffff;
            background: #0f1c17;
        }

        #tray:hover {
        	border-radius: 5px 20px 5px 20px;
        	background: #484a4a;
        }

        @keyframes blink {
            to {
                background-color: #eb4034;
                color: #484a4a;
            }
        }
      '';
    };

    home.file.".config/waybar/scripts/cava.sh" = {
      text = ''

      '';
      executable = true;
    };

    home.file.".config/waybar/scripts/spotify.sh" = {
      text = ''
        #!/bin/sh

        status=$(playerctl --player=spotify status 2>/dev/null)

        if [[ "$status" == "Playing" ]] || [[ "$status" == "Paused" ]]; then
            artist=$(playerctl --player=spotify metadata artist)
            title=$(playerctl --player=spotify metadata title)
            echo "$artist - $title"
        else
            echo ""
        fi
      '';
      executable = true;
    };
  };

  programs.home-manager.enable = true;
}
