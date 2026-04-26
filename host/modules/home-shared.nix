{
  pkgs,
  inputs,
  ...
}: {
  home = {
    username = "isma";
    homeDirectory = "/home/isma";
    stateVersion = "25.05";

    # Keep only lightweight/shared essentials here.
    packages = with pkgs; [
      nixd
      tree
      btop
      yazi
      eza
      bat
      ripgrep
      p7zip
      unrar
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

        # Rebuilds by machine: ns = nixos switch, nb = nixos boot, nt = nixos test
        nsd = "sudo nixos-rebuild switch --flake .#desktop";
        nbd = "sudo nixos-rebuild boot --flake .#desktop";
        ntd = "sudo nixos-rebuild test --flake .#desktop";
        nsl = "sudo nixos-rebuild switch --flake .#laptop";
        nbl = "sudo nixos-rebuild boot --flake .#laptop";
        ntl = "sudo nixos-rebuild test --flake .#laptop";
        nss = "sudo nixos-rebuild switch --flake .#server";
        nbs = "sudo nixos-rebuild boot --flake .#server";
        nts = "sudo nixos-rebuild test --flake .#server";

        # Cleanup
        ngc = "sudo nix-collect-garbage -d";
        nclean = "sudo nix-collect-garbage -d && nix store gc";
        helpnix = "printf '%s\n' 'Alias legend:' '  nf*  -> nix flake tasks (nfup, nfck, nfsync)' '  ns*  -> nixos-rebuild switch' '  nb*  -> nixos-rebuild boot' '  nt*  -> nixos-rebuild test' '  *d/*l/*s -> desktop/laptop/server' 'Examples: nsd, nsl, nss, nbd, ntl'";
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

    fastfetch.enable = true;
  };
}
