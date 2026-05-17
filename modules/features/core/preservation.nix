# preservation.nix — Impermanence via nix-community/preservation
{ inputs, ... }: {
  flake.nixosModules.preservation = { lib, userName, ... }: {
    imports = [ inputs.preservation.nixosModules.preservation ];

    # ── Ephemeral root: enable systemd-based initrd ────────────────────────
    boot.initrd.systemd.enable = lib.mkDefault true;

    # ── Everything that must survive a reboot lives under /persist ─────────
    preservation = {
      enable = true;
      preserveAt."/persist" = {
        directories = [
          # ── System identity ─────────────────────────────────────────────
          { directory = "/etc/ssh";                            inInitrd = true;  }
          { directory = "/var/lib/systemd";                   inInitrd = false; }
          { directory = "/var/lib/bluetooth";                 inInitrd = false; }
          { directory = "/etc/NetworkManager/system-connections"; inInitrd = false; }
          { directory = "/var/lib/sops-nix";                  inInitrd = false; }

          # ── Service state ────────────────────────────────────────────────
          { directory = "/var/lib/postgresql";                inInitrd = false; }
          { directory = "/var/lib/jellyfin";                  inInitrd = false; }
          { directory = "/var/lib/sonarr";                    inInitrd = false; }
          { directory = "/var/lib/radarr";                    inInitrd = false; }
          { directory = "/var/lib/lidarr";                    inInitrd = false; }
          { directory = "/var/lib/readarr";                   inInitrd = false; }
          { directory = "/var/lib/bazarr";                    inInitrd = false; }
          { directory = "/var/lib/prowlarr";                  inInitrd = false; }
          { directory = "/var/lib/seerr";                     inInitrd = false; }
          { directory = "/var/lib/qbittorrent-nox";           inInitrd = false; }
          { directory = "/var/lib/nextcloud";                 inInitrd = false; }
          { directory = "/var/lib/nextcloud-data";            inInitrd = false; }
          { directory = "/var/lib/redis-nextcloud";           inInitrd = false; }
          { directory = "/var/lib/navidrome";                 inInitrd = false; }
          { directory = "/var/lib/kavita";                    inInitrd = false; }
          { directory = "/var/lib/kiwix";                     inInitrd = false; }
          { directory = "/var/lib/ollama";                    inInitrd = false; }
          { directory = "/var/lib/open-webui";                inInitrd = false; }
          { directory = "/var/lib/tailscale";                 inInitrd = false; }
          { directory = "/var/lib/libvirt";                   inInitrd = false; }
          { directory = "/var/lib/containers";                inInitrd = false; }
          { directory = "/var/lib/flatpak";                   inInitrd = false; }
          { directory = "/var/log";                           inInitrd = false; }

          # ── User critical dot-dirs ───────────────────────────────────────
          # /home is its own persistent BTRFS subvol; these bind-mounts are a
          # safety net in case the home subvol is ever intentionally wiped.
          { directory = "/home/${userName}/.config";          inInitrd = false; }
          { directory = "/home/${userName}/.local";           inInitrd = false; }
          { directory = "/home/${userName}/.ssh";             inInitrd = false; }
          { directory = "/home/${userName}/.gnupg";           inInitrd = false; }
        ];

        files = [
          # Stable machine-id (journald cursor, systemd-id128)
          "/etc/machine-id"
        ];
      };
    };
  };
}
