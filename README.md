# Filosofo

NixOS and Home Manager configuration organized by host and user profiles.

## Repository Layout

    flake.nix

    assets/
    └── Static assets

    host/
    ├── modules/
    │   ├── home-shared.nix ← Shared home config for isma
    │   ├── system-base.nix ← Shared system base config
    │   ├── graphical.nix   ← Shared desktop environment config
    │   ├── gaming.nix      ← Shared gaming config
    │   ├── development.nix ← Shared development services/tools
    │   └── default.nix     ← Module index/registry
    ├── desktop/
    │   ├── default.nix
    │   ├── hardware-configuration.nix
    │   └── home.nix        ← imports ../modules/home-shared.nix
    ├── laptop/
    │   ├── default.nix
    │   ├── hardware-configuration.nix
    │   └── home.nix        ← imports ../modules/home-shared.nix
    └── server/
        ├── default.nix
        └── hardware-configuration.nix
        
    secrets/
        └── secrets.nix

## Alias Legend

Fish aliases are defined in `host/modules/home-shared.nix`.

- `nf*` = nix flake tasks:
  - `nfup` (update), `nfck` (check), `nfsync` (update + check)
- `ns*` / `nb*` / `nt*` = `nixos-rebuild` mode:
  - `ns` = switch, `nb` = boot, `nt` = test
- Host suffix:
  - `d` = desktop, `l` = laptop, `s` = server

Examples:

- `nsd` = switch desktop
- `nsl` = switch laptop
- `nss` = switch server
- `nbd` = boot desktop
- `ntl` = test laptop
