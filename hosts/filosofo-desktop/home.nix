{
  pkgs,
  inputs,
  lib,
  username,
  gitUsername,
  gitEmail,
  isDesktop,
  isServer,
  ...
}: let
  wall1 = "${inputs.self}/assets/staticwall";
  wall2 = "${inputs.self}/assets/animatedwall";
  # AI generated wrapper script for random logos in fastfetch
  fastfetchRandomLogoScript = pkgs.writeShellApplication {
    name = "fastfetch-random-logo";
    # Ensure necessary tools are available in the script's path
    runtimeInputs = [pkgs.fastfetch pkgs.findutils pkgs.gnugrep pkgs.gnushuf pkgs.coreutils]; # coreutils for `xargs`

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
in {
  # Paths and users home manager should manage
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";

  home.stateVersion = "25.05"; # Do not change this shit either

  nixpkgs.config.allowUnfree = true;

  # STYLIX JUNK
  stylix.enable = true;
  stylix.polarity = "dark";
  stylix.targets.firefox.profileNames = ["${username}"];
  stylix.targets.qt.enable = true;
  stylix.targets.gtk.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-soft.yaml";

  home.packages = with pkgs; [
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

    # Terminal-based tools and utilities
    cool-retro-term # A cool retro terminal emulator
    fastfetch # Modern system info tool
    asciiquarium
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

  qt.enable = true;
  gtk.enable = true;

  wayland.windowManager.hyprland = lib.mkIf isDesktop {
    enable = true;
    xwayland.enable = true;
    systemd.variables = ["--all"];

    settings = {
      exec-once = [
        "swww init"
        "swww img $(find ${wall1} ${wall2} -type f \\( -name '*.jpg' -o -name '*.png' -o -name '*.jpeg' -o -name '*.gif' \\) | shuf -n 1)"
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

    kitty.enable = true;

    waybar = {
      enable = true;
      systemd.enable = true;
      settings = {
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
          source = "null";
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
