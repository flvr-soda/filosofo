# Filosofo

NixOS and Home Manager configuration strictly organized using the **Dendritic pattern** and `flake-parts`.

## Architecture & The Dendritic Pattern

This project structure avoids monolithic, manual import registries. Instead, we use `import-tree` combined with `flake-parts` to automatically evaluate and export self-sufficient modules directly into the flake outputs.

Every `.nix` file inside the `modules/` directory acts as a top-level `flake-parts` module that independently declares the configuration it exports (`flake.nixosModules.<name>` or `flake.nixosConfigurations.<name>`).

## Repository Layout

    flake.nix           ← Flake entrypoint configuring import-tree

    modules/
    ├── nixosModules/   ← Reusable system and Home Manager modules
    │   ├── core.nix        ← Exposes global variables (e.g. userName) to all modules
    │   ├── base.nix        ← Shared system base config
    │   ├── graphical.nix   ← Shared desktop environment config
    │   ├── gaming.nix      ← Shared gaming config
    │   ├── development.nix ← Shared development services/tools
    │   ├── secrets.nix     ← Agenix module integration
    │   ├── shared.nix      ← Core Home Manager and Agenix setup
    │   ├── shell.nix       ← Shell configuration (Fish, Starship, etc)
    │   └── users.nix       ← User accounts and Home Manager profiles
    │   └── virtualization.nix ← Virtualization configuration
    │
    └── hosts/          ← Configuration for specific system hosts
        ├── desktop/
        │   ├── default.nix
        │   └── hardware-configuration.nix
        ├── laptop/
        │   ├── default.nix
        │   └── hardware-configuration.nix
        └── server/
            ├── default.nix
            └── hardware-configuration.nix
        
    secrets/            ← Managed by Agenix (not imported by import-tree)
    ├── secrets.nix         ← Agenix encryption mapping
    ├── user-password.age
    └── github-ssh-key.age

## Alias Legend

Fish aliases are defined in `modules/nixosModules/users.nix`.

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
