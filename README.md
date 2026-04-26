# Filosofo

NixOS and Home Manager configuration organized by host and user profiles.

## Repository Layout

    flake.nix

    assets/
    └── Static assets

    host/
    ├── common.nix          ← Shared home config for isma
    ├── default.nix         ← Shared system config
    ├── desktop/
    │   ├── default.nix
    │   ├── hardware-configuration.nix
    │   └── home.nix        ← imports ../common.nix
    ├── laptop/
    │   ├── default.nix
    │   ├── hardware-configuration.nix
    │   └── home.nix        ← imports ../common.nix
    └── server/
        └── default.nix
        
    secrets/
        └── secrets.nix
