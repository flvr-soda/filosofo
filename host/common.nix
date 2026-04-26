{
  pkgs,
  inputs,
  ...
}: {

  home = {
    username = "isma";
    homeDirectory = "/home/isma";
    stateVersion = "25.05";

    packages = with pkgs; [
      qbittorrent-enhanced
      vlc
      texstudio
      libreoffice
      miktex
      kew
      kiwix
      imagemagick
      nixd
      google-antigravity
      fastfetch
      tree
      cava
      cmatrix
      btop
      yazi
      eza
      bat
      ripgrep
      ffmpeg
      proxychains
      medusa
      nmap
      whois
      sqlmap
      wireshark
      aircrack-ng
      p7zip
      unrar
      wine
      protonup-ng
      winetricks
    ];
  };

  programs = {
    home-manager.enable = true;

    fish = {
      enable = true;
      interactiveShellInit = ''
        set -g fish_color_autosuggestion brblack
        set -U fish_greeting ""
      '';
      shellAliases = {
        nfu = "nix flake update";
        ncg = "sudo nix-collect-garbage -d";
        l = "eza -lh --icons=auto";
        ls = "eza -1 --icons=auto";
        ll = "eza -lha --icons=auto --sort=name --group-directories-first";
        ld = "eza -lhD --icons=auto";
        lt = "eza --icons=auto --tree";
      };
    };

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
        init.defaultBranch = "main";
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
        extensions.packages = with inputs.firefox-addons.packages.${pkgs.system}; [
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
        "git.autofetch" = true;
        "nix.serverPath" = "nixd";
        "security.workspace.trust.banner" = "never";
        "files.autoSave" = "afterDelay";
        "editor.minimap.autohide" = "mouseover";
      };
    };

    fastfetch.enable = true;
  };
}
