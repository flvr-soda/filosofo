{
  pkgs,
  inputs,
  ...
}:{
  nixpkgs.overlays = [ inputs.nur.overlays.default ];
  nixpkgs.config.allowUnfree = true;
  home = {
    # Paths and users home manager should manage
    username = "isma";
    homeDirectory = "/home/isma";
    stateVersion = "25.05"; # Do not change this

    packages = with pkgs; [
      # Applications for general use and productivity
      qbittorrent-enhanced
      vlc
      texstudio
      libreoffice
      miktex
      kew
      kiwix
      imagemagick
      sphinx
      nixd

      # Terminal-based tools and utilities
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

      # Cybersecurity
      proxychains
      medusa
      nmap
      whois
      sqlmap
      wireshark
      aircrack-ng

      # Compression/Archive tools
      p7zip
      unrar

      # Windows compatibility and gaming tools
      wine
      protonup-ng
      winetricks
    ];
  };

  # User program settings
  programs = {
    fish = {
      enable = true;
      interactiveShellInit = ''
        set -g fish_color_autosuggestion brblack
        set -U fish_greeting ""
      '';
      shellAliases = {
        nfu  = "nix flake update";
        ncg = "sudo nix-collect-garbage -d";
        l = "eza -lh --icons=auto"; # long list
        ls = "eza -1 --icons=auto"; # short list
        ll = "eza -lha --icons=auto --sort=name --group-directories-first"; # long list all
        ld = "eza -lhD --icons=auto"; # long list dirs
        lt = "eza --icons=auto --tree"; # list folder as tree
      };
    };

    # Starship prompt
    starship = {
      enable = true;
      enableFishIntegration = true;
    };

    git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user = {
          name = "flvr-soda";  
          email = "iearmada@proton.me";  
          useConfigOnly = false;
        };
        init.defaultBranch = "main";  # Default branch name
        url."ssh://git@github.com/".insteadOf = "https://github.com/";
      };
    };

    firefox = {
      enable = true;
      profiles.isma = {
        settings = {
          "dom.security.https_only_mode" = true;
          "browser.download.panel.shown" = true;
          "identity.fxaccounts.enabled" = false;
          "signon.rememberSignons" = false;
        };
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          bitwarden
        ];
      };
    };

    vscode = {
      enable = true;
      package = pkgs.vscodium;
      profiles.default.userSettings = {
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "security.workspace.trust.banner" = "never";
        "files.autoSave" = "afterDelay";
        "editor.minimap.autohide" = "mouseover";
      };
    };

    fastfetch = {
      enable = true;
    };     
  };
  programs.home-manager.enable = true;
}
