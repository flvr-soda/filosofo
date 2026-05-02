{ self, inputs, ... }: {
  flake.nixosModules.shell = {
    pkgs,
    userName,
    ...
  }: {
    # NixOS System-Level Configuration

    # Ensure Fish is available globally and set it as the user's login shell
    programs.fish.enable = true;
    users.users.${userName}.shell = pkgs.fish;

    # Home Manager User-Level Configuration
    
    home-manager.users.${userName} = { pkgs, ... }: {

      # Modern CLI tools — co-located with their program configs below
      home.packages = with pkgs; [
        eza
        bat
        fd
        ripgrep
        fzf
        zoxide
        btop
        yazi
        # Use the wrapped fastfetch from our flake outputs
        self.packages.${pkgs.stdenv.hostPlatform.system}.fastfetch
      ];

      # Smart prompt
      programs.starship = {
        enable = true;
        enableFishIntegration = true;
        # Clean, modern preset
        settings = {
          add_newline = true;
          character = {
            success_symbol = "[➜](bold green)";
            error_symbol = "[➜](bold red)";
          };
          directory = {
            truncation_length = 3;
            truncate_to_repo = true;
          };
          nix_shell = {
            symbol = "❄️ ";
            format = "via [$symbol$state( \\($name\\))]($style) ";
          };
          git_branch = {
            symbol = "🌱 ";
          };
        };
      };

      # Advanced shell integration
      programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
      };

      programs.fzf = {
        enable = true;
        enableFishIntegration = true;
      };

      # Fish Shell Customization
      programs.fish = {
        enable = true;
        interactiveShellInit = ''
          set -g fish_color_autosuggestion brblack
          set -U fish_greeting ""
        '';
        shellAliases = {
          # Modern alternatives
          ls = "eza --icons --group-directories-first";
          ll = "eza -lh --icons --group-directories-first";
          la = "eza -a --icons --group-directories-first";
          tree = "eza --tree --icons";
          cat = "bat";
          top = "btop";
          grep = "rg";
          cd = "z";
          
          # Nix Maintenance
          nfup = "nix flake update";
          nfck = "nix flake check";
          nfmt = "nix fmt";
          nrepl = "nix repl";
          ngc = "sudo nix-collect-garbage -d";
          nclean = "sudo nix-collect-garbage -d && nix store gc";
          
          # Smart NixOS Rebuilds (detects current host)
          ns = "sudo nixos-rebuild switch --flake .";
          nb = "sudo nixos-rebuild boot --flake .";
          nt = "sudo nixos-rebuild test --flake .";
          
          # Explicit host aliases (kept for convenience)
          nsd = "sudo nixos-rebuild switch --flake .#desktop";
          nsl = "sudo nixos-rebuild switch --flake .#laptop";
          nss = "sudo nixos-rebuild switch --flake .#server";
        };
      };
    };
  };

  perSystem = { pkgs, ... }: {
    packages.fastfetch = inputs.wrapper-modules.wrappers.fastfetch.wrap {
      inherit pkgs;
      settings = {
        logo = {
          source = "nixos";
          padding = {
            right = 4;
          };
        };
        display = {
          size = {
            binaryPrefix = "jedec";
          };
          color = "magenta";
        };
        modules = [
          "title"
          "separator"
          "os"
          "host"
          "kernel"
          "uptime"
          "packages"
          "shell"
          "display"
          "de"
          "wm"
          "wmtheme"
          "theme"
          "icons"
          "font"
          "cursor"
          "terminal"
          "terminalfont"
          "cpu"
          "gpu"
          "memory"
          "disk"
          "battery"
          "poweradapter"
          "locale"
          "break"
          "colors"
        ];
      };
    };
  };
}
