{ pkgs, ... }: {
  programs = {
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
