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
              nmap
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

              background = "#242424";
              foreground = "#ebdbb2";
              cursor = "#ebdbb2";
              selection_foreground = "#504945";
              selection_background = "#3c3836";
              active_tab_foreground = "#b8bb26";
              active_tab_background = "#665c54";
              inactive_tab_background = "#3c3836";

              color0 = "#242424";
              color8 = "#504945";
              color1 = "#fb4934";
              color9 = "#fb4934";
              color2 = "#b8bb26";
              color10 = "#b8bb26";
              color3 = "#fabd2f";
              color11 = "#fabd2f";
              color4 = "#7daea3";
              color12 = "#7daea3";
              color5 = "#e089a1";
              color13 = "#e089a1";
              color6 = "#8ec07c";
              color14 = "#8ec07c";
              color7 = "#665c54";
              color15 = "#665c54";
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

              ports = "sudo ss -tulpn";
              myip = "curl -s https://ipinfo.io/ip; echo";
              localip = "ip -brief address";
              msf = "msfconsole -q";
              proxy = "proxychains4";
              nscan = "nmap -T4 -F";
              nscan-full = "nmap -p- -A -T4 -v";
              nscan-vuln = "nmap -sV --script=vuln";
              sniff = "sudo tcpdump -i any -c 100 -nn";
              hasher = "sha256sum";
               list-aliases = "alias";
            };
          };
        };

        programs.fish.enable = true;
        users.users.${userName}.shell = pkgs.fish;
      };
    };
}
