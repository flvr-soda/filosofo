{
  pkgs,
  inputs,
  config,
  userName,
  ...
}: {
  home = {
    username = userName;
    homeDirectory = "/home/${userName}";
    stateVersion = "25.05";

    packages = with pkgs; [
      nixd
      btop
      yazi
      eza
      bat
      ripgrep
      p7zip
      unrar
      wine
      protonup-ng
      winetricks
      libreoffice
      google-antigravity
      kiwix
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
        # Flake workflow
        nfup = "nix flake update";
        nfck = "nix flake check";
        nfmt = "nix fmt";
        nfsync = "nix flake update && nix flake check";
        nrepl = "nix repl";
        # Desktop
        nsd = "sudo nixos-rebuild switch --flake .#desktop";
        nbd = "sudo nixos-rebuild boot --flake .#desktop";
        ntd = "sudo nixos-rebuild test --flake .#desktop";
        # Laptop
        nsl = "sudo nixos-rebuild switch --flake .#laptop";
        nbl = "sudo nixos-rebuild boot --flake .#laptop";
        ntl = "sudo nixos-rebuild test --flake .#laptop";
        # Server
        nss = "sudo nixos-rebuild switch --flake .#server";
        nbs = "sudo nixos-rebuild boot --flake .#server";
        nts = "sudo nixos-rebuild test --flake .#server";
        # Cleanup
        ngc = "sudo nix-collect-garbage -d";
        nclean = "sudo nix-collect-garbage -d && nix store gc";
        helpnix = "printf '%s\n' 'Alias legend:' '  nf*  -> nix flake tasks (nfup, nfck, nfsync)' '  ns*  -> nixos-rebuild switch' '  nb*  -> nixos-rebuild boot' '  nt*  -> nixos-rebuild test' '  *d/*l/*s -> desktop/laptop/server' 'Examples: nsd, nsl, nss, nbd, ntl'";
        # Misc
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

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {
          addKeysToAgent = "yes";
        };
        "github.com" = {
          hostname = "github.com";
          identityFile = "~/.ssh/id_github";
        };
      };
    };

    git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user = {
          name = "flvr-soda";
          email = "iearmada@proton.me";
        };
        init.defaultBranch = "main";
        url."git@github.com:".insteadOf = "https://github.com/";
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

    firefox = {
      enable = true;
      configPath = "${config.xdg.configHome}/mozilla/firefox";
      profiles.${userName} = {
        settings = {
          "dom.security.https_only_mode" = true;
          "browser.download.panel.shown" = true;
          "identity.fxaccounts.enabled" = false;
          "signon.rememberSignons" = false;
        };
        extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
          ublock-origin
          bitwarden
        ];
        search = {
          force = true;
          default = "ddg";
        };
      };
    };

    fastfetch.enable = true;
  };
}
