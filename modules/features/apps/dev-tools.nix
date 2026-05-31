# apps/dev-tools.nix — Developer tooling suite.
# Taxonomy: features/apps/dev-tools.nix
# Covers: Git, Lazygit, VSCodium, LLM Agents, Google Antigravity (FHS-wrapped via jacopone/antigravity-nix).
#          Also includes: benchmarking (hyperfine) and database clients (beekeeper-studio, psql).
#          Supersedes: toolchains.nix, database-clients.nix (merged here; those files are deleted).
{ self, inputs, lib, ... }: {
  flake.nixosModules.dev-tools = { config, pkgs, userName, userEmail, gitName, ... }:
    let
      cfg = config.filosofo.features.dev-tools;
      agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
      antigravityPkgs = inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      options.filosofo.features.dev-tools.enable =
        lib.mkEnableOption "Enable developer tools (Git, Lazygit, VSCodium, Antigravity)";

      config = lib.mkIf cfg.enable {
        home-manager.users.${userName} = { pkgs, ... }: {

          xdg.configFile = {
            "devenv/ml/devenv.nix".source = ../../../devenv/ml/devenv.nix;
            "devenv/ml/devenv.yaml".source = ../../../devenv/ml/devenv.yaml;

            "devenv/embedded/devenv.nix".source = ../../../devenv/embedded/devenv.nix;
            "devenv/embedded/devenv.yaml".source = ../../../devenv/embedded/devenv.yaml;

            "devenv/fullstack/devenv.nix".source = ../../../devenv/fullstack/devenv.nix;
            "devenv/fullstack/devenv.yaml".source = ../../../devenv/fullstack/devenv.yaml;

            "devenv/pentest/devenv.nix".source = ../../../devenv/pentest/devenv.nix;
            "devenv/pentest/devenv.yaml".source = ../../../devenv/pentest/devenv.yaml;

            "devenv/rust/devenv.nix".source = ../../../devenv/rust/devenv.nix;
            "devenv/rust/devenv.yaml".source = ../../../devenv/rust/devenv.yaml;
          };

          programs.vscodium = {
            enable = true;
            profiles.default.userSettings = {
              "nix.enableLanguageServer"           = true;
              "nix.serverPath"                     = "nixd";
              "git.autofetch"                      = true;
              "security.workspace.trust.banner"    = "never";
              "files.autoSave"                     = "afterDelay";
              "editor.minimap.autohide"            = "mouseover";
              "http.systemCertificatesNode"        = true;
            };
          };

          programs.git = {
            enable   = true;
            settings = {
              user = { name = gitName; email = userEmail; };
              alias = {
                st   = "status -sb";
                lg   = "log --oneline --graph --decorate --all";
                undo = "reset --soft HEAD^";
                wip  = "commit -am 'WIP'";
              };
              init.defaultBranch    = "main";
              push.autoSetupRemote  = true;
              pull.rebase           = true;
              core.autocrlf         = "input";
              credential.helper     = "store";
            };
          };

          home.packages = with pkgs;
            [
              lazygit
              gitflow
              git-lfs
              gh
              eza
              bat
              fd
              ripgrep
              fzf
              zoxide
              btop
              yazi
              fastfetch
              devenv
              wireshark
              tcpdump
              whois
              proxychains
              medusa
              hashcat
              ghidra
              hyperfine
              beekeeper-studio
              postgresql_16 # psql CLI
              # AI Agents
              agents.goose-cli
              agents.jules
              agents.crush
              agents.hermes
              # Google Antigravity (dedicated FHS-wrapped packages)
              antigravityPkgs.google-antigravity      # Base App 2.0
              antigravityPkgs.google-antigravity-ide   # IDE
              antigravityPkgs.google-antigravity-cli   # agy CLI
            ];

          programs.kitty = {
            enable = true;
            font = {
              name = "JetBrainsMono Nerd Font";
              size = 15;
            };
            settings = {
              enable_audio_bell = "no";
              cursor_text_color = "background";
              allow_remote_control = "yes";
              shell_integration = "enabled";
              cursor_trail = 3;
            };
            keybindings = {
              "alt+1" = "goto_tab 1";
              "alt+2" = "goto_tab 2";
              "alt+3" = "goto_tab 3";
              "alt+4" = "goto_tab 4";
              "alt+5" = "goto_tab 5";
              "alt+6" = "goto_tab 6";
              "alt+7" = "goto_tab 7";
              "alt+8" = "goto_tab 8";
              "alt+9" = "goto_tab 9";
              "ctrl+shift+w" = "close_tab";
              "ctrl+t" = "new_tab_with_cwd";
              "ctrl+shift+t" = "new_tab";
            };
          };

          programs.starship = {
            enable = true;
            enableFishIntegration = true;
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

          programs.zoxide = {
            enable = true;
            enableFishIntegration = true;
          };

          programs.fzf = {
            enable = true;
            enableFishIntegration = true;
          };

          programs.fish = {
            enable = true;
            interactiveShellInit = ''
              set -g fish_color_autosuggestion brblack
              set -U fish_greeting ""
            '';
            shellAliases = {
              ls = "eza --icons --group-directories-first";
              ll = "eza -lh --icons --group-directories-first";
              la = "eza -a --icons --group-directories-first";
              tree = "eza --tree --icons";
              cat = "bat";
              top = "btop";
              grep = "rg";
              cd = "z";
              lzg = "lazygit";
              yz = "yazi";
              ff = "fastfetch";
              find = "fd";
              fzf-hist = "history | fzf";

              nfup = "nix flake update";
              nfck = "nix flake check";
              nfmt = "nix fmt";
              nrepl = "nix repl";
              ngc = "nh clean";
              nclean = "nh clean all";
              nb = "nh os build";
              ns = "nh os switch";
              nsd = "nh os switch --dry";
              nboot = "nh os boot";
              nstat = "nix-store --gc --print-dead";
              nsys = "systemctl list-units --failed";
              nlog = "journalctl -xeu";

              col = "colmena";
              ca = "colmena apply";
              cab = "colmena apply --build-on-target";
              cbl = "colmena build";
              ce = "colmena eval";
              cad = "colmena apply --on desktop";
              cas = "colmena apply --on server";
              cal = "colmena apply --on laptop";

              g = "git";
              gs = "git status -sb";
              gd = "git diff";
              gco = "git checkout";
              gcl = "git clone";
              gl = "git log --oneline --graph --decorate --all";
              nsh = "nix develop -c \$SHELL";

              # Devenv quick environment launch aliases
              devenv-ml = "devenv shell --config ~/.config/devenv/ml/devenv.yaml";
              devenv-embedded = "devenv shell --config ~/.config/devenv/embedded/devenv.yaml";
              devenv-fullstack = "devenv shell --config ~/.config/devenv/fullstack/devenv.yaml";
              devenv-pentest = "devenv shell --config ~/.config/devenv/pentest/devenv.yaml";
              devenv-rust = "devenv shell --config ~/.config/devenv/rust/devenv.yaml";
            };
          };
        };

        programs.fish.enable = true;
        users.users.${userName}.shell = pkgs.fish;
      };
    };
}
