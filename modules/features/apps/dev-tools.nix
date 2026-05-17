# apps/dev-tools.nix — Developer tooling suite.
# Taxonomy: features/apps/dev-tools.nix
# Covers: Git, Lazygit, VSCodium, Google Antigravity (FHS-isolated).
{ self, inputs, lib, ... }: {
  flake.nixosModules.dev-tools = { config, pkgs, userName, userEmail, gitName, ... }:
    let
      cfg = config.filosofo.features.dev-tools;
      antigravityPkg =
        inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.default or null;
    in
    {
      options.filosofo.features.dev-tools.enable =
        lib.mkEnableOption "Enable developer tools (Git, Lazygit, VSCodium, Antigravity)";

      config = lib.mkIf cfg.enable {
        home-manager.users.${userName} = { pkgs, ... }: {

          # ── VSCodium ────────────────────────────────────────────────────
          programs.vscodium = {
            enable = true;
            profiles.default.userSettings = {
              "nix.enableLanguageServer"           = true;
              "nix.serverPath"                     = "nixd";
              "git.autofetch"                      = true;
              "security.workspace.trust.banner"    = "never";
              "files.autoSave"                     = "afterDelay";
              "editor.minimap.autohide"            = "mouseover";
            };
          };

          # ── Git global config ───────────────────────────────────────────
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
              gh          # GitHub CLI
              # CLI Tools
              eza
              bat
              fd
              ripgrep
              fzf
              zoxide
              btop
              yazi
              fastfetch
              # Cybersec
              nmap
              burpsuite
              wireshark
              tcpdump
              whois
              proxychains
              aircrack-ng
              medusa
              sqlmap
              metasploit
              ghidra
              john
            ]
            ++ lib.optional (antigravityPkg != null) antigravityPkg;

          # ── Smart prompt ──────────────────────────────────────────────────
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

          # ── Fish Shell ────────────────────────────────────────────────────
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
              nfup = "nix flake update";
              nfck = "nix flake check";
              nfmt = "nix fmt";
              nrepl = "nix repl";
              ngc = "nh clean";
              nclean = "nh clean all";
              nb = "nh os build";
              ns = "nh os switch";
            };
          };
        };

        programs.fish.enable = true;
        users.users.${userName}.shell = pkgs.fish;
      };
    };
}
