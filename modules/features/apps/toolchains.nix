# apps/toolchains.nix — Compilers, runtimes, and low-level build utilities.
# Taxonomy: features/apps/toolchains.nix
# Covers: Python3, Ninja, GCC, Valgrind, CMake, Rust, LLVM, strace, etc.
{ lib, ... }: {
  flake.nixosModules.toolchains = { config, pkgs, userName, ... }:
    let
      cfg = config.filosofo.features.toolchains;
    in
    {
      options.filosofo.features.toolchains.enable =
        lib.mkEnableOption "Enable compiler toolchains and build utilities";

      config = lib.mkIf cfg.enable {
        home-manager.users.${userName} = { pkgs, ... }: {
          home.packages = with pkgs; [
            # ── Compilers & Build Systems ──────────────────────────────────
            gcc
            gnumake
            cmake
            pkg-config
            meson
            ninja

            # ── Language Runtimes ──────────────────────────────────────────
            openjdk
            python3
            python3Packages.pip
            rustup

            # ── Debugging & Profiling ──────────────────────────────────────
            gdb
            lldb
            valgrind
            hyperfine    # CLI benchmarking
            strace
            ltrace

            # ── DevOps ────────────────────────────────────────────────────
            act        # Run GitHub Actions locally
            k9s        # Kubernetes TUI
            kubectl
          ];
        };
      };
    };
}
