# filosofo

Unified [NixOS](https://nixos.org/) flake for a small home fleet: **laptop**, **desktop**, and **server**, with shared trunk configuration and atomic feature toggles.

## Architecture (for humans and agents)

| Principle | How it is expressed here |
|-----------|---------------------------|
| **Atomic features** | `filosofo.features.<name>.enable` in feature modules under [`modules/features/`](modules/features/). One toggle per concern where practical. |
| **Flake parts + import-tree** | [`flake.nix`](flake.nix) uses `flake-parts.lib.mkFlake` and `(inputs.import-tree ./modules)`. Nix fragments under [`modules/`](modules/) merge into one flake. Paths containing `/_` are ignored by import-tree — host helpers live as [`_role-imports.nix`](modules/hosts/desktop/_role-imports.nix) / [`_role-defaults.nix`](modules/hosts/desktop/_role-defaults.nix) next to each host. |
| **Secrets** | [sops-nix](https://github.com/Mic92/sops-nix). Encrypted tree: [`secrets/secrets.yaml`](secrets/secrets.yaml). Rules: [`.sops.yaml`](.sops.yaml). Edit: `nix shell nixpkgs#sops -c sops secrets/secrets.yaml`. Host decryption uses `/etc/ssh/ssh_host_ed25519_key` (see `sops.age.sshKeyPaths` in [`modules/features/core/secrets.nix`](modules/features/core/secrets.nix)). |
| **Home Manager** | Wired in [`modules/features/core/shared.nix`](modules/features/core/shared.nix); user defaults in [`globals.nix`](modules/features/core/globals.nix). |
| **Declarative reverse proxy** | `filosofo.services.proxy` (schema in [`modules/features/core/services.nix`](modules/features/core/services.nix)) + Caddy in [`modules/features/services/caddy.nix`](modules/features/services/caddy.nix). |
| **Program wrappers** | [nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules) — see [`modules/features/apps/wrappers.nix`](modules/features/apps/wrappers.nix). |

### Media layout (locked policy)

- **`*ARR` automation only** — [`modules/features/services/arr-stack.nix`](modules/features/services/arr-stack.nix): Sonarr, Radarr, Prowlarr, Lidarr, Readarr, Bazarr, qBittorrent, Jellyseerr (seerr), Homarr, etc. No Jellyfin or other streaming servers in this file.
- **Streaming / libraries** stay **separate modules**: [`jellyfin.nix`](modules/features/services/jellyfin.nix), [`kavita.nix`](modules/features/services/kavita.nix), [`navidrome.nix`](modules/features/services/navidrome.nix). Hosts choose imports via [`_role-imports.nix`](modules/hosts/desktop/_role-imports.nix) lists.
- Shared paths: `mediaGroup` / `mediaPath` in [`modules/features/core/globals.nix`](modules/features/core/globals.nix).

### Hosts and roles

| Output | Hardware module | Role (imports + defaults) |
|--------|------------------|---------------------------|
| `nixosConfigurations.desktop` | [`desktop/hardware-configuration.nix`](modules/hosts/desktop/hardware-configuration.nix) | [`desktop/_role-imports.nix`](modules/hosts/desktop/_role-imports.nix) + [`_role-defaults.nix`](modules/hosts/desktop/_role-defaults.nix) |
| `nixosConfigurations.laptop` | [`laptop/hardware-configuration.nix`](modules/hosts/laptop/hardware-configuration.nix) | [`laptop/_role-*.nix`](modules/hosts/laptop/) |
| `nixosConfigurations.server` | [`server/hardware-configuration.nix`](modules/hosts/server/hardware-configuration.nix) | [`server/_role-*.nix`](modules/hosts/server/) |

Machine-specific disks, `tmpfiles`, and SSH tweaks stay in each [`configuration.nix`](modules/hosts/desktop/configuration.nix).

## Secrets layout (`secrets/secrets.yaml`)

YAML keys (underscores) expected by the modules:

| Key | Used by |
|-----|---------|
| `user_password` | `users.users.<name>.hashedPasswordFile` (`neededForUsers`) |
| `github_ssh_key` | Home Manager symlink `~/.ssh/id_github` |
| `nextcloud_admin_password` | Nextcloud `adminpassFile` |
| `homarr_secret_key` | Homarr container `environmentFiles` (`SECRET_ENCRYPTION_KEY=…`) |
| `kavita_token` | Kavita `tokenKeyFile` |
| `navidrome_password` | Navidrome `PasswordEncryptionKey` path |
| `tailscale_authkey` | Tailscale `authKeyFile` when `filosofo.features.tailscale.headlessJoin` |

**Migrating from old agenix `.age` files** (still in `secrets/` for reference): decrypt with your age identities, then `sops secrets/secrets.yaml` and paste values under the keys above. When satisfied, you may remove `secrets/*.age`.

**New host key:** add `ssh-to-age` output for `ssh_host_ed25519_key.pub` to [`.sops.yaml`](.sops.yaml), then `sops updatekeys secrets/secrets.yaml`.

## Validation

```bash
nix flake check   # formatter + light nixos eval checks (hostName files)
nix build .#nixosConfigurations.desktop.config.system.build.toplevel   # full system closure when needed
```

## Compared to [homeserver-nixos](https://github.com/rwiankowski/homeserver-nixos) README (high level)

| Area | filosofo |
|------|----------|
| Caddy + internal DNS-style names | Yes (`filosofo.services.proxy`) |
| Tailscale | Yes |
| *ARR + Jellyfin ecosystem | Yes (*ARR module; Jellyfin/Kavita/Navidrome separate) |
| Nextcloud + Postgres + Redis | Yes (Nextcloud module) |
| Ollama + Open WebUI | Yes ([`ai.nix`](modules/features/services/ai.nix)) |
| Pi-hole, Kiwix | Yes |
| SSO (e.g. Authentik) | Not in-tree |
| Grafana / Prometheus | Not in-tree (optional later) |
| Restic / cloud backups | Out of scope for current plan cycle |
| CrowdSec | Not in-tree |

## References

- [vimjoyer/nixconf](https://github.com/vimjoyer/nixconf) — flake-parts + fileset patterns.
- [rwiankowski/homeserver-nixos](https://github.com/rwiankowski/homeserver-nixos) — service density and ops ideas.

## Agent read order

1. [`flake.nix`](flake.nix) — inputs and `mkFlake` entry.
2. [`modules/features/core/globals.nix`](modules/features/core/globals.nix) — shared `_module.args`, flake checks.
3. [`modules/features/core/base.nix`](modules/features/core/base.nix) — trunk imports.
4. Host [`configuration.nix`](modules/hosts/desktop/configuration.nix) + matching `_role-*.nix`.
5. Feature module under [`modules/features/`](modules/features/) for the service you touch.
6. [`.sops.yaml`](.sops.yaml) + [`secrets/secrets.yaml`](secrets/secrets.yaml) when adding secrets.

Preserve the **automation vs streamer** split in media modules; extend `.sops.yaml` when adding recipients.
