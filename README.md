# Filosofo — Declarative, Dendritic NixOS Infrastructure Flake

Welcome to Filosofo, an advanced, highly structured, and elegant NixOS configuration repository managed entirely as a reproducible flake. Designed with modern aesthetics, absolute reproducibility, and modular purity, this configuration manages a fleet of host machines seamlessly. [:-D]

---

## Architectural Philosophy: The Dendritic Pattern

Filósofo is designed using a strictly dendritic (tree-like) architecture. In this scheme:
*   Passive Module Discovery: Files are structured as independent atomic modules loaded passively using import-tree and flake-parts.
*   Atom Isolation: No module inside modules/features/ is allowed to directly import another using relative paths.
*   Logical Interlocking: Feature cross-talk is achieved entirely through the NixOS evaluation system by exposing options and conditionally reacting to changes.

---

## Core Toolchain

*   flake-parts: Simplifies structure and multi-architecture evaluations under a unified interface.
*   import-tree: Enables passive, directory-based module loading.
*   disko: Strict declarative drive partitioning and BTRFS-on-LUKS setups.
*   preservation: Impermanence orchestration preserving critical files on an ephemeral system.
*   nix-wrapper-modules: Ergonomic wrappers for customized compositors and tools (such as Niri, wlr-which-key, and Noctalia).
*   sops-nix: Seamless encryption and decryption of host and user secrets via Age keys.

---

## Taxonomy of Features (modules/features/)

Every NixOS module resides in a well-defined structure:

### 1. features/core/
The immutable system layer required for fundamental operation:
*   boot.nix and networking.nix: Bootloader configurations and core network services.
*   users.nix: Secure user declarations and shell management.
*   hardware.nix: Centralized driver support (amdgpu, OpenGL, Vulkan, AMD ROCm).
*   preservation.nix: Ephemeral base system setup keeping only required system and user state.
*   secrets.nix: SOPS orchestration and decryption key settings.

### 2. features/apps/
The user-facing interactive graphical workspace:
*   ui.nix (Niri, Noctalia, theme wrappers): Fluid modern Wayland environment with active layout swapping.
*   dev-tools.nix: Declarative Home Manager settings for Git, Fish, Starship, and modern Gruvbox-style kitty.
*   media.nix: Graphical video/audio players (mpv + uosc plugins), image viewer (loupe), and archive viewer (file-roller).
*   productivity.nix: Offline suite Editors (onlyoffice, obsidian, zotero).
*   gaming.nix: Optimizations for hardware gaming (Steam, Wine).

### 3. features/services/
Background processes and server stacks:
*   databases.nix: Global single-instance PostgreSQL database that other services conditionally inject schemas/users into.
*   tailscale.nix: Zero-trust mesh VPN linking all devices securely.
*   virtualization.nix: Declarative container running (Docker, Kubernetes).
*   homelab/ (master switch services.homelab.full-stack): Media suite containing Jellyfin (with hardware acceleration), Sonarr, Radarr, Lidarr, Bazarr, qBittorrent, and Nextcloud.
*   ai/ (master switch services.ai.local-inference): Inferences via Ollama (configured with AMD ROCm acceleration), Open-WebUI (backed by local PostgreSQL), and SearXNG search engine.

---

## Fleet Hosts & Deployment

We define and target three core environments, plus a custom builder:
*   desktop: Powerful workstation utilizing Core + Apps + Homelab + AI inference + massive AMD GPU acceleration.
*   laptop: Portable station optimized for single SSD layouts, using local desktop applications and remote AI.
*   server: Headless, pure-software homelab container server configured remotely.
*   installer: Custom GNOME graphical installation Live CD containing pre-loaded installation shell scripts.

### Rebuild and Fleet Deployment Commands:
*   Local Updates: Use nh for streamlined rebuilds on the physical host:
    ```bash
    nh os switch . -- --ask
    ```
*   Fleet Deployments: Use colmena to securely push updates from your laptop or desktop directly onto remote servers (like the headless homelab server):
    ```bash
    colmena apply --on server
    ```

---

## Storage & Ephemeral State Management

We implement a clean Impermanence setup to ensure system purity:
1.  Ephemeral Root: / is mounted as a fast tmpfs RAM disk (cleared entirely at every boot).
2.  State Persistence: All permanent data is explicitly mapped using the preservation module to a persistent BTRFS subvolume mounted on /persist (e.g. /var/log, /var/lib/systemd, user SSH keys, and SOPS files).
3.  Drive Partitioning: Declarative partition systems are specified via disko:
    *   Laptop: Single SSD layout with LUKS encryption.
    *   Desktop: High-performance OS SSD and mapped high-capacity HDD /storage drive.

---

## Installation on New Devices

Installing Filosofo on a new machine is fully automated via our custom Live CD:

1.  Boot the Installer: Burn and boot the custom installer Live ISO.
2.  Cloning Configuration: Use the custom alias to pull your configuration:
    ```bash
    clone-repo
    ```
3.  Run Partitioning & Installation: Run the automated setup helper matching your target device:
    *   To install on a desktop:
        ```bash
        install-desktop
        ```
    *   To install on a laptop:
        ```bash
        install-laptop
        ```
    *   To install on a headless server:
        ```bash
        install-server
        ```
4.  **Reboot**: Once finished, reboot the device. Your ephemeral system will boot cleanly into a fully-configured Niri/Noctalia environment!

---

## Custom Live CD Shell Aliases

Our custom Live environment registers these helpful shell commands inside _installer.nix:

| Shell Alias | Command | Description |
| :--- | :--- | :--- |
| clone-repo | git clone https://github.com/flvr-soda/filosofo.git | Clones this repository into the live session. |
| install-desktop | sudo nix run github:nix-community/disko/latest -- --mode disko --flake .#desktop && sudo nixos-install --flake .#desktop | Partition drive via Disko and bootstrap Desktop system. |
| install-laptop | sudo nix run github:nix-community/disko/latest -- --mode disko --flake .#laptop && sudo nixos-install --flake .#laptop | Partition drive via Disko and bootstrap Laptop system. |
| install-server | sudo nix run github:nix-community/disko/latest -- --mode disko --flake .#server && sudo nixos-install --flake .#server | Partition drive via Disko and bootstrap Homelab Server system. |

---

## Fish Shell Aliases

Your interactive shell environment includes a list of pre-configured shortcuts and aliases. You can instantly view them all inside your shell by running:
```bash
list-aliases
```

Here is the complete categorized reference of the defined aliases:

### 1. Navigation & Modern Command-Line Alternatives
*   `ls`: `eza --icons --group-directories-first` (Modern directory listings)
*   `ll`: `eza -lh --icons --group-directories-first` (Detailed lists with permissions)
*   `la`: `eza -a --icons --group-directories-first` (Include hidden files)
*   `tree`: `eza --tree --icons` (Recursive directory visual trees)
*   `cat`: `bat` (Visual text viewer with syntax highlighting)
*   `top`: `btop` (Rich interactive terminal resource monitor)
*   `grep`: `rg` (Fast, multi-threaded pattern matching)
*   `cd`: `z` (Fuzzy navigation database jumping)
*   `find`: `fd` (Speedy, simple search helper)
*   `yz`: `yazi` (Fast and gorgeous file manager interface)
*   `lzg`: `lazygit` (Premium interactive TUI for Git control)
*   `ff`: `fastfetch` (System visual details and hardware fetcher)
*   `fzf-hist`: `history \| fzf` (Interactive terminal command history selection)

### 2. NixOS, Rebuilds, & System Maintenance
*   `nfup`: `nix flake update` (Update all repository inputs)
*   `nfck`: `nix flake check` (Evaluate full configuration validations)
*   `nfmt`: `nix fmt` (Format all flake files)
*   `nrepl`: `nix repl` (Interactive Nix language playground)
*   `ngc`: `nh clean` (Clean standard builds and cache)
*   `nclean`: `nh clean all` (Absolute deep garbage collection cleanup)
*   `nb`: `nh os build` (Compile standard build package)
*   `ns`: `nh os switch` (Apply layout rebuild and switch system)
*   `nsd`: `nh os switch --dry` (Pre-eval rebuild dry run)
*   `nboot`: `nh os boot` (Rebuild configuration for next system boot)
*   `nstat`: `nix-store --gc --print-dead` (Print system dead store paths)
*   `nsh`: `nix develop -c \$SHELL` (Activate devShell in current environment)
*   `nsys`: `systemctl list-units --failed` (Instantly view broken background services)
*   `nlog`: `journalctl -xeu` (Real-time system services viewer logs)

### 3. Colmena Remote Deployments
*   `col`: `colmena` (Colmena multi-node orchestrator tool)
*   `ca`: `colmena apply` (Apply remote configurations to fleet)
*   `cab`: `colmena apply --build-on-target` (Build closures directly on the target host)
*   `cbl`: `colmena build` (Test-build all hosts closures locally)
*   `ce`: `colmena eval` (Run dry evaluations on nodes)
*   `cad`: `colmena apply --on desktop` (Deploy configuration to desktop)
*   `cas`: `colmena apply --on server` (Deploy configuration to server)
*   `cal`: `colmena apply --on laptop` (Deploy configuration to laptop)

### 4. Version Control (Git) Shortcuts
*   `g`: `git`
*   `gs`: `git status -sb` (Clean status overview)
*   `gd`: `git diff` (Review unstaged changes)
*   `gco`: `git checkout` (Switch files or branches)
*   `gcl`: `git clone` (Download remote repository)
*   `gl`: `git log --oneline --graph --decorate --all` (Visual git commit tree graph)

### 5. Advanced Security & Network Diagnostics
*   `ports`: `sudo ss -tulpn` (List active listening sockets)
*   `myip`: `curl -s https://ipinfo.io/ip; echo` (Display public WAN address)
*   `localip`: `ip -brief address` (Display local hardware interface states)
*   `msf`: `msfconsole -q` (Launch quiet Metasploit penetration suite)
*   `proxy`: `proxychains4` (Proxy chains connection wrapper)
*   `nscan`: `nmap -T4 -F` (Quick network ports scan)
*   `nscan-full`: `nmap -p- -A -T4 -v` (Full aggressive port scan)
*   `nscan-vuln`: `nmap -sV --script=vuln` (Aggressive vulnerability scan)
*   `sniff`: `sudo tcpdump -i any -c 100 -nn` (Interactive packet capture)
*   `hasher`: `sha256sum` (Compute sha256 checksums)
*   `list-aliases`: `alias` (Interactive list of all current terminal shortcuts)
