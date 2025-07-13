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

  # AI generated wrapper script for wallpaper setting because idk how to do it
  randomWall = pkgs.writeShellApplication {
    name = "random-wallpaper";
    runtimeInputs = with pkgs; [
      swww # For setting the wallpaper
      pywal # For generating colors
      findutils # For 'find'
      coreutils # For 'shuf' and 'head'
      dunst # For notifications (if dunst is enabled)
    ];
    text = ''
      # Define the directory where your wallpapers are stored
      wallpaper_dir="${wallpaperDir}"

      # Find all image files (png, jpg, jpeg) in the wallpaper directory
      # -print0 and xargs -0 are used for robust handling of filenames with spaces or special characters.
      all_wallpapers=$(find "$wallpaper_dir" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) -print0)

      # Check if any wallpapers were found
      if [ -z "$all_wallpapers" ]; then
        echo "No wallpapers found in $wallpaper_dir. Cannot set wallpaper or run wal." >&2
        ${pkgs.dunst}/bin/dunstify "Wallpaper Error" "No wallpapers found in $wallpaper_dir." -u critical || true
        exit 1
      fi

      # Randomly pick one wallpaper from the list
      random_wallpaper=$(echo "$all_wallpapers" | xargs -0 shuf -n 1)

      if [ -z "$random_wallpaper" ]; then
        echo "Failed to pick a random wallpaper." >&2
        ${pkgs.dunst}/bin/dunstify "Wallpaper Error" "Failed to pick a random wallpaper." -u critical || true
        exit 1
      fi

      # Set the wallpaper using swww
      echo "Setting wallpaper: $random_wallpaper"
      ${pkgs.swww}/bin/swww img "$random_wallpaper" --transition-type grow --transition-pos 0.9,0.9 --transition-step 90 --transition-duration 3

      # Apply pywal colors from the chosen wallpaper
      echo "Applying pywal colors from: $random_wallpaper"
      ${pkgs.pywal}/bin/wal -i "$random_wallpaper"

      # Optional: Notify the user that the wallpaper and colors have been updated
      wallpaper_name=$(basename "$random_wallpaper")
      ${pkgs.dunst}/bin/dunstify "Wallpaper & Theme Updated" "New wallpaper: <b>$wallpaper_name</b>\nColors applied by Pywal." -i "$random_wallpaper" || true
    '';
  };

  # AI generated wrapper script for random logos in fastfetch
  randomLogoScript = pkgs.writeShellApplication {
    name = "fastfetch-random-logo";
    # Ensure necessary tools are available in the script's path
    runtimeInputs = with pkgs; [
      fastfetch
      findutils
      gnugrep
      coreutils
    ];

    text = ''
      # Define the paths to the asset directories in the Nix store.
      # These paths are fixed at build time due to how Nix works,
      # but they correctly point to the assets copied into the store.
      logo_dir="${config.home.homeDirectory}/pictures/logos"


      # Find all .txt files in ascii_dir and .png files in png_dir
      # -print0 and xargs -0 are used for robust handling of filenames with spaces or special characters.
      all_logos_list=$(
        find "$logo_dir" -type f \( -name "*.txt" -o -name "*.gif" \) -print0 || true
      )

      # Check if any logos were found
      if [ -z "$all_logos_list" ]; then
        echo "No logo files found in $logo_dir. Using default fastfetch logo." >&2
        exec "${pkgs.fastfetch}/bin/fastfetch" "$@"
        exit $?
      fi

      # Randomly pick one logo from the combined list
      # shuf -n 1 needs the input to be newline-separated or null-separated.
      # xargs -0 takes null-separated input and passes it as arguments, then printf converts to newline.
      random_logo=$(echo "$all_logos_list" | xargs -0 printf '%s\n' | shuf -n 1)

      if [ -z "$random_logo" ]; then
        echo "Failed to pick a random logo. Using default fastfetch logo." >&2
        exec "${pkgs.fastfetch}/bin/fastfetch" "$@"
        exit $?
      fi

      # Execute fastfetch with the randomly chosen logo, passing through all arguments
      exec "${pkgs.fastfetch}/bin/fastfetch" --logo-source "$random_logo" "$@"
    '';
  };
in {
  nixpkgs.config.allowUnfree = true;

  home = {
    # Paths and users home manager should manage
    username = "${username}";
    homeDirectory = "/home/${username}";
    stateVersion = "25.05"; # Do not change this shit either};
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

      # SCRIPTS
      randomLogoScript
      randomWall

      # Terminal-based tools and utilities
      cool-retro-term # A cool retro terminal emulator
      fastfetch # Modern system info tool
      asciiquarium
      tree
      ascii-image-converter
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

      # Utility for automounting removable media
      udiskie
    ];
  };

  # STYLIX JUNK
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
        "${randomWall}/bin/random-wallpaper"
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

          "$mod, W, exec, ${randomWall}/bin/random-wallpaper"

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

          #"$mod, M, exec, next-wallpaper next"
          #"$mod, N, exec, next-wallpaper prev"
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
        kb_layout = "la,us"; # US and Spanish layouts
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
        ff = "fastfetch-random-logo";
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
        mainBar = {
          # Bar properties
          layer = "top";
          position = "top";
          height = 30; # Adjust to your preference
          margin-bottom = 5;

          # Define which modules go where
          modules-left = [
            "hyprland/workspaces"
            "hyprland/window"
          ];

          modules-center = [
            "clock"
          ];

          modules-right = [
            "cpu"
            "memory"
            "battery"
            "pulseaudio"
            "tray"
          ];

          # Module-specific configurations
          "hyprland/workspaces" = {
            format = "{icon}";
            format-icons = {
              active = "";
              default = "";
            };
            persistent-workspaces = {
              "1" = [];
              "2" = [];
              "3" = [];
              "4" = [];
              "5" = [];
            };
            on-scroll-up = "hyprctl dispatch workspace e-1";
            on-scroll-down = "hyprctl dispatch workspace e+1";
          };

          "hyprland/window" = {
            max-length = 30;
            format = "{title}";
          };

          "clock" = {
            format = " {:%H:%M}"; # Time
            format-alt = " {:%d/%m/%Y}"; # Date
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          };

          "cpu" = {
            format = " {usage}%";
            tooltip = false;
            on-click = "";
          };

          "memory" = {
            format = " {used:0.1f}G";
            tooltip = true;
          };

          "battery" = {
            format = "{icon} {capacity}%";
            format-charging = " {capacity}%";
            format-plugged = " {capacity}%";
            format-icons = ["" "" "" "" ""];
            # Adjust these paths based on your setup
            path = "/sys/class/power_supply/BAT1/uevent";
            # Setting for tooltip-format and states based on charge
            tooltip-format = "{time}";
            states = {
              warning = 20;
              critical = 10;
            };
          };

          "pulseaudio" = {
            format = " {volume}%";
            format-muted = " {volume}%";
            scroll-step = 1;
            on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
            on-scroll-up = "pactl set-sink-volume @DEFAULT_SINK@ +5%";
            on-scroll-down = "pactl set-sink-volume @DEFAULT_SINK@ -5%";
          };

          "tray" = {
            spacing = 10;
          };
        };
      };

      style = ''
        * {
          border: none;
          border-radius: 0;
          font-family: monospace;
          font-size: 14px;
        }

        window#waybar {
          background: rgba(43, 48, 59, 0.5);
          color: #ffffff;
        }

        /* Define the styling for each module */
        #workspaces button {
          padding: 0 5px;
          background: transparent;
          color: #ffffff;
          border-bottom: 2px solid transparent;
        }

        #workspaces button.active {
          border-bottom: 2px solid #64727D;
        }

        #workspaces button:hover {
          background: #5A606C;
        }

        #clock {
          padding: 0 10px;
          background: #64727D;
        }

        #cpu, #memory, #battery, #pulseaudio, #tray {
          padding: 0 10px;
          background: #333333;
          margin-right: 5px;
        }

        #battery.warning {
          color: #FF5555;
        }
      '';
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
      settings = {
        logo = {
          source = null;
          height = 20;
          padding = {
            right = 1;
          };
        };
        display = {
          size = {
            binaryPrefix = "si";
          };
          separator = "  ";
        };
        modules = [
          {
            type = "custom";
            format = "┌──────────────────────────────────────────┐";
          }
          {
            type = "chassis";
            key = "  󰇺 Chassis";
            format = "{1} {2} {3}";
          }
          {
            type = "os";
            key = "  󰣇 OS";
            format = "{2}";
            keyColor = "red";
          }
          {
            type = "kernel";
            key = "   Kernel";
            format = "{2}";
            keyColor = "red";
          }
          {
            type = "packages";
            key = "  󰏗 Packages";
            keyColor = "green";
          }
          {
            type = "display";
            key = "  󰍹 Display";
            format = "{1}x{2} @ {3}Hz [{7}]";
            keyColor = "green";
          }
          {
            type = "terminal";
            key = "   Terminal";
            keyColor = "yellow";
          }
          {
            type = "wm";
            key = "  󱗃 WM";
            format = "{2}";
            keyColor = "yellow";
          }
          {
            type = "custom";
            format = "└──────────────────────────────────────────┘";
          }
          "break"
          {
            type = "title";
            key = "  ";
            format = "{6} {7} {8}";
          }
          {
            type = "custom";
            format = "┌──────────────────────────────────────────┐";
          }
          {
            type = "cpu";
            format = "{1} @ {7}";
            key = "   CPU";
            keyColor = "blue";
          }
          {
            type = "gpu";
            format = "{1} {2}";
            key = "  󰊴 GPU";
            keyColor = "blue";
          }
          {
            type = "gpu";
            format = "{3}";
            key = "   GPU Driver";
            keyColor = "magenta";
          }
          {
            type = "memory";
            key = "   Memory ";
            keyColor = "magenta";
          }
          {
            type = "disk";
            key = "  󱦟 OS Age ";
            folders = "/";
            keyColor = "red";
            format = "{days} days";
          }
          {
            type = "uptime";
            key = "  󱫐 Uptime ";
            keyColor = "red";
          }
          {
            type = "custom";
            format = "└──────────────────────────────────────────┘";
          }
          {
            type = "colors";
            paddingLeft = 2;
            symbol = "circle";
          }
          "break"
        ];
      };
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

  programs.home-manager.enable = true;
}
