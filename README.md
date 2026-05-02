# Filósofo

A modular, highly structured NixOS configuration built on the **Pure Dendritic Pattern** and **`flake-parts`**. This project prioritizes atomic features, declarative program wrapping, and automatic module discovery.

## Architecture

This repository uses a state-of-the-art Nix architecture:

- **`flake-parts`**: Provides a modular framework for managing flake outputs.
- **Pure Dendritic Pattern**: Every file in the `modules/` directory is automatically discovered and imported via `import-tree`. No manual import registries are needed.
- **Wrapper Modules**: Leverages `nix-wrapper-modules` to configure CLI tools like `fastfetch` using structured Nix attribute sets instead of flat config files.
- **Single Source of Truth**: `modules/features/core/globals.nix` injects global variables (username, timezone, etc.) throughout the entire configuration tree.

## Repository Structure

```text
.
├── flake.nix               # Minimalist entrypoint using import-tree
├── modules/
│   ├── features/           # Atomic, reusable system features
│   │   ├── core/           # System foundation (Boot, Shell, Secrets, etc.)
│   │   ├── dev/            # Specialized dev environments (Programming, DBs, etc.)
│   │   ├── apps/           # GUI Apps & Desktop (Firefox, Plasma, Gaming)
│   │   └── services/       # Standalone services (Jellyfin, NAS, AI)
│   └── hosts/              # Machine-specific configurations
│       ├── desktop/        # Workstation config
│       ├── laptop/         # Mobile config (Battery optimized)
│       └── server/         # Media & AI server (Headless optimized)
└── secrets/                # Encrypted secrets managed by Agenix
```

## Usage

The project includes smart shell aliases (defined in `modules/features/core/shell.nix`) to simplify system management.

### System Rebuilds
- `ns`: Switch current host configuration (`nixos-rebuild switch`)
- `nb`: Boot current host configuration (`nixos-rebuild boot`)
- `nt`: Test current host configuration (`nixos-rebuild test`)

### Specific Host Aliases
- `nsd`: Switch Desktop
- `nsl`: Switch Laptop
- `nss`: Switch Server

### Flake Maintenance
- `nfup`: Update flake inputs
- `nfck`: Check flake syntax and validity
- `nfmt`: Format all Nix files

## Key Features

- **Desktop**: Plasma 6 on Wayland with SDDM.
- **Browsing**: Hardened Firefox with custom privacy settings and bookmarks.
- **Development**:
  - Languages: GCC, Python, OpenJDK.
  - Databases: PostgreSQL, MariaDB (MariaDB).
  - Containers: Docker & Docker Compose.
  - Cybersec: Nmap, sqlmap, aircrack-ng, medusa.
  - Hardware: KiCad, Arduino IDE/CLI.
- **Services**:
  - Jellyfin: Media streaming.
  - Ollama: Local AI models (deepseek, tinyllama).
  - Virtualization: KVM/QEMU via libvirt and virt-manager.
- **Security**: Agenix for encrypted secrets, Apparmor, and hardened SSH.

## Hardware Configuration

Hardware configurations (`hardware-configuration.nix`) are wrapped as flake-parts modules. This allows them to be part of the dendritic tree while remaining easy to re-generate if the hardware changes.
