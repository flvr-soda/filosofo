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

    programs.home-manager.enable = true;
  };
}
