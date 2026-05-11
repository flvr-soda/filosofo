# Programming — atomic development feature.
# Covers: compilers, build tools, language runtimes, git, IDE tooling.
# antigravity-nix is wired directly from the flake input.
{ self, inputs, lib, ... }: {
  flake.nixosModules.programming = { config, pkgs, userName, userEmail, gitName, ... }:
    let
      cfg = config.filosofo.features.programming;
      # Resolve the system-appropriate antigravity package from flake input
      antigravityPkg = inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
        or null;
    in
    {
      options.filosofo.features.programming = {
        enable = lib.mkEnableOption "Enable the programming & development tools feature";
        enableHardwareDev = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Arduino IDE/CLI, KiCAD, serial tools (minicom, screen, picocom), udev rules
            for Arduino boards, and dialout/tty group membership for serial access.
          '';
        };
      };

      config = lib.mkMerge [
        (lib.mkIf cfg.enable {

        home-manager.users.${userName} = { pkgs, ... }: {
          home.packages = with pkgs;
            [
              # ── Compilers & Build Systems ──────────────────────────────
              gcc
              gnumake
              cmake
              pkg-config
              meson
              ninja

              # ── Language Runtimes ──────────────────────────────────────
              openjdk
              python3
              python3Packages.pip
              rustup

              # ── Version Control ────────────────────────────────────────
              git
              gitflow
              git-lfs
              gh                  # GitHub CLI
              lazygit             # TUI git client

              # ── Debugging & Profiling ──────────────────────────────────
              gdb
              lldb
              valgrind
              hyperfine           # CLI benchmarking
              strace
              ltrace

              # ── CI/CD & DevOps ─────────────────────────────────────────
              act                 # Run GitHub Actions locally
              k9s                 # Kubernetes TUI
              kubectl

              # ── IDEs ───────────────────────────────────────────────────
              # VSCodium is in vscode.nix (always-on app module)
              code-cursor
            ]
            ++ lib.optional (antigravityPkg != null) antigravityPkg
            ++ lib.optionals cfg.enableHardwareDev (with pkgs; [
              arduino-ide
              arduino-cli
              kicad
              minicom             # Serial terminal
              screen              # Alternate serial terminal
              picocom             # Minimal serial client
            ]);

          # ── Git Global Config ──────────────────────────────────────────
          programs.git = {
            enable = true;
            settings = {
              user = {
                name = gitName;
                email = userEmail;
              };
              alias = {
                st = "status -sb";
                lg = "log --oneline --graph --decorate --all";
                undo = "reset --soft HEAD^";
                wip = "commit -am 'WIP'";
              };
              init.defaultBranch = "main";
              push.autoSetupRemote = true;
              pull.rebase = true;
              core.autocrlf = "input";
              # Avoid credential prompts in terminals
              credential.helper = "store";
            };
          };

        };
        })
        (lib.mkIf (cfg.enable && cfg.enableHardwareDev) {
          users.users.${userName}.extraGroups = [ "dialout" "tty" ];
          services.udev.packages = [ pkgs.arduino-ide ];
        })
      ];
    };
}
