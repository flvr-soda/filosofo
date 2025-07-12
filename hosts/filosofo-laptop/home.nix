{
  pkgs,
  inputs,
  lib,
  username,
  gitUsername,
  gitEmail,
  isDesktop,
  ...
}: let
  wall1 = "${inputs.self}/assets/staticwall";
  wall2 = "${inputs.self}/assets/animatedwall";

  # AI generated wrapper script for random logos in fastfetch
  randomLogoScript = pkgs.writeShellApplication {
    name = "fastfetch-random-logo";
    # Ensure necessary tools are available in the script's path
    runtimeInputs = [pkgs.fastfetch pkgs.findutils pkgs.gnugrep pkgs.coreutils]; # coreutils for `xargs`

    text = ''
      # Define the paths to the asset directories in the Nix store.
      # These paths are fixed at build time due to how Nix works,
      # but they correctly point to the assets copied into the store.
      ascii_dir="${inputs.self}/assets/ascii"
      png_dir="${inputs.self}/assets/png"

      # Find all .txt files in ascii_dir and .png files in png_dir
      # -print0 and xargs -0 are used for robust handling of filenames with spaces or special characters.
      all_logos_list=$(
        find "$ascii_dir" -type f -name "*.txt" -print0 || true
        find "$png_dir" -type f -name "*.png" -print0 || true
      )

      # Check if any logos were found
      if [ -z "$all_logos_list" ]; then
        echo "No logo files found in $ascii_dir or $png_dir. Using default fastfetch logo." >&2
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

  # AI generated wrapper script for wallpaper cycling (TO DO: PYWAL INTEGRATION)
  wallChange = pkgs.writeShellApplication {
    name = "next-wallpaper";
    runtimeInputs = [pkgs.swww pkgs.findutils pkgs.gnugrep pkgs.coreutils];

    text = ''
      #!${pkgs.bash}/bin/bash
      set -euxo pipefail # Added for robust error checking and debugging output

      WALL_DIR_1="${wall1}"
      WALL_DIR_2="${wall2}"
      # Use XDG_CACHE_HOME if available, otherwise default to ~/.cache
      CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}"
      STATE_FILE="$CACHE_DIR/swww_current_wallpaper_index"
      WALLPAPER_LIST_FILE="$CACHE_DIR/swww_wallpaper_list"

      echo "DEBUG: WALL_DIR_1=$WALL_DIR_1"
      echo "DEBUG: WALL_DIR_2=$WALL_DIR_2"
      echo "DEBUG: STATE_FILE=$STATE_FILE"
      echo "DEBUG: WALLPAPER_LIST_FILE=$WALLPAPER_LIST_FILE"

      mkdir -p "$(dirname "$STATE_FILE")"

      # Generate a sorted list of all wallpapers if it doesn't exist or is empty.
      if [ ! -s "$WALLPAPER_LIST_FILE" ]; then
          echo "DEBUG: Wallpaper list file is missing or empty. Regenerating..."
          # Use -iname for case-insensitivity, which is more portable than -iregex.
          find "$WALL_DIR_1" "$WALL_DIR_2" -type f \( \
              -iname "*.jpg" -o \
              -iname "*.jpeg" -o \
              -iname "*.png" -o \
              -iname "*.gif" \
          \) | sort > "$WALLPAPER_LIST_FILE"
      fi

      # Check if the list is still empty after generation
      if [ ! -s "$WALLPAPER_LIST_FILE" ]; then
          echo "Error: No wallpapers found in specified directories: $WALL_DIR_1, $WALL_DIR_2. Exiting." >&2
          exit 1
      fi

      # Read the list of wallpapers safely into the ALL_WALLPAPERS array
      mapfile -t ALL_WALLPAPERS < "$WALLPAPER_LIST_FILE"

      # Remove empty lines that might result from the mapfile command
      for i in "''${!ALL_WALLPAPERS[@]}"; do
        [ -n "''${ALL_WALLPAPERS[$i]}" ] || unset "ALL_WALLPAPERS[$i]"
      done


      NUM_WALLPAPERS=''${#ALL_WALLPAPERS[@]}
      echo "DEBUG: Number of wallpapers found: $NUM_WALLPAPERS"

      if (( NUM_WALLPAPERS == 0 )); then
          echo "Error: Wallpaper list file contained no valid paths after parsing. Exiting." >&2
          exit 1
      fi

      CURRENT_INDEX=0
      # Check if state file exists and has content
      if [ -s "$STATE_FILE" ]; then
          # Read the index and validate it
          read -r temp_index < "$STATE_FILE"
          echo "DEBUG: Read temp_index from state file: '$temp_index'"
          if [[ "$temp_index" =~ ^[0-9]+$ ]] && (( temp_index >= 0 && temp_index < NUM_WALLPAPERS )); then
              CURRENT_INDEX=$temp_index
              echo "DEBUG: Valid index from state file: $CURRENT_INDEX"
          else
              echo "DEBUG: Invalid index ('$temp_index') or out of bounds. Resetting to random."
              CURRENT_INDEX=$(( RANDOM % NUM_WALLPAPERS ))
          fi
      else
          echo "DEBUG: State file not found or empty. Starting with random index."
          CURRENT_INDEX=$(( RANDOM % NUM_WALLPAPERS ))
      fi
      echo "DEBUG: Final CURRENT_INDEX before setting wallpaper: $CURRENT_INDEX"

      ACTION="''${1:-}" # Use parameter expansion to avoid errors if $1 is not set
      echo "DEBUG: Action: $ACTION"

      NEW_INDEX=$CURRENT_INDEX
      if [ "$ACTION" = "next" ]; then
          NEW_INDEX=$(( (CURRENT_INDEX + 1) % NUM_WALLPAPERS ))
      elif [ "$ACTION" = "prev" ]; then
          NEW_INDEX=$(( (CURRENT_INDEX - 1 + NUM_WALLPAPERS) % NUM_WALLPAPERS ))
      fi
      echo "DEBUG: NEW_INDEX after action: $NEW_INDEX"


      NEW_WALLPAPER="''${ALL_WALLPAPERS[$NEW_INDEX]}"
      echo "DEBUG: NEW_WALLPAPER: $NEW_WALLPAPER"


      # --- START OF THE MAIN FIX ---
      # Safely build the command using a bash array

      swww_args=()
      swww_args+=("img")
      swww_args+=("$NEW_WALLPAPER") # The wallpaper path is now a separate, safe element

      # Define transition settings
      SELECTED_TRANSITION_TYPE="grow"
      TRANSITION_FPS="60"
      TRANSITION_DURATION="0.7"
      TRANSITION_STEP="90"
      TRANSITION_ANGLE=""
      TRANSITION_BEZIER=""
      TRANSITION_POS=""

      # Set conditional options
      if [ "$SELECTED_TRANSITION_TYPE" = "grow" ]; then
          TRANSITION_POS="center"
      fi

      # Add arguments to the array
      swww_args+=("--transition-type" "$SELECTED_TRANSITION_TYPE")
      swww_args+=("--transition-fps" "$TRANSITION_FPS")
      swww_args+=("--transition-duration" "$TRANSITION_DURATION")
      swww_args+=("--transition-step" "$TRANSITION_STEP")

      # Add optional arguments only if they have a value
      if [ -n "$TRANSITION_ANGLE" ]; then
          swww_args+=("--transition-angle" "$TRANSITION_ANGLE")
      fi
      if [ -n "$TRANSITION_POS" ]; then
          swww_args+=("--transition-pos" "$TRANSITION_POS")
      fi
      if [ -n "$TRANSITION_BEZIER" ]; then
          swww_args+=("--transition-bezier" "$TRANSITION_BEZIER")
      fi

      # Execute the command safely
      # The ''${swww_args[@]} expansion ensures every element is treated as a distinct argument
      echo "DEBUG: Executing swww command: ''${pkgs.swww}/bin/swww" "''${swww_args[@]}"
      "''${pkgs.swww}/bin/swww" "''${swww_args[@]}"

      # --- END OF THE MAIN FIX ---

      echo "$NEW_INDEX" > "$STATE_FILE"

      echo "Wallpaper set to: $NEW_WALLPAPER (Index: $NEW_INDEX) with transition: $SELECTED_TRANSITION_TYPE"
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
      wallChange

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
      rofi-wayland # Application launcher/switcher (Wayland compatible)
      swww # Wallpaper utility
      clipse # Clipboard manager (ensure this is a Wayland-compatible one if needed)
      grimblast # Screenshot utility for Wayland
      slurp

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

  qt.enable = true;
  gtk.enable = true;

  wayland.windowManager.hyprland = lib.mkIf isDesktop {
    enable = true;
    xwayland.enable = true;
    systemd.variables = ["--all"];
    settings = {
      exec-once = [
        "swww init"
        #"swww img $(find ${wall1} ${wall2} -type f \\( -name '*.jpg' -o -name '*.png' -o -name '*.jpeg' -o -name '*.gif' \\) | shuf -n 1)"
        "next-wallpaper"
        "dunst"
        "udiskie"
        "nm-applet"
      ];
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
      };

      decoration = {
        shadow_offset = "0 5";
        "col.shadow" = "rgba(00000099)";
        blur = {
          enabled = true;
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
          "$mod, K, exec, kew"
          "$mod, A, exec, rofi-wayland -show drun"
          "$mod SHIFT, M, exec, btop"

          "$mod, Q, killactive"
          "$mod SHIFT, F, togglefloating"
          "$mod, F, fullscreen"

          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"

          "$mod SHIFT, h, movewindow, l"
          "$mod SHIFT, l, movewindow, r"
          "$mod SHIFT, k, movewindow, u"
          "$mod SHIFT, j, movewindow, d"

          "$mod, M, exec, next-wallpaper next"
          "$mod, N, exec, next-wallpaper prev"
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
    };
  };

  programs = {
    pywal.enable = true;

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
      #systemd.enable = true;

      settings = {
        "main-bar" = {
          # You can name your bar whatever you like, e.g., "top-bar", "laptop-bar"
          layer = "top";
          position = "top";
          height = 30;
          spacing = 5;

          modules-left = ["hyprland/workspaces" "hyprland/window"];
          modules-center = ["clock"];
          modules-right = ["cpu" "memory" "battery" "pulseaudio" "network" "tray"];

          "hyprland/workspaces" = {
            format = "{icon}";
            format-icons = {
              "1" = "";
              "2" = "";
              "3" = "";
              "urgent" = "";
              "focused" = "";
              "default" = "";
            };
          };

          clock = {
            format = " {:%H:%M}   {:%Y-%m-%d}";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          };

          pulseaudio = {
            format = "{icon} {volume}%";
            format-muted = " Muted";
            format-icons = {
              default = ["" "" ""];
            };
            on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          };

          battery = {
            format = "{icon} {capacity}%";
            format-charging = "充電 {capacity}%"; # Unicode for charging symbol
            format-plugged = "電源 {capacity}%"; # Unicode for plugged in symbol
            format-alt = "{time} {icon}";
            format-full = " {capacity}%";
            format-icons = ["" "" "" "" ""];
            states = {
              good = 90;
              warning = 30;
              critical = 15;
            };
            tooltip-format = "{time} left";
          };

          tray = {
            icon-size = 18;
            spacing = 10;
          };

          network = {
            format-wifi = " {essid}";
            format-ethernet = " {ifname}";
            format-disconnected = " No Network";
            tooltip-format = "{ifname}: {ipaddr}";
          };

          cpu = {
            format = " {usage}%";
            tooltip = false;
          };

          memory = {
            format = " {used:0.1f}G";
            tooltip = false;
          };
        };
      };
    };

    starship = {
      enable = true;
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
