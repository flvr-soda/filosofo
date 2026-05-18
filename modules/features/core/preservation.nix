# preservation.nix — Impermanence via nix-community/preservation
{ inputs, ... }: {
  flake.nixosModules.preservation = { lib, userName, ... }: {
    imports = [ inputs.preservation.nixosModules.preservation ];

    # Preservation requires systemd-based initrd to mount the persistent root during boot.
    boot.initrd.systemd.enable = lib.mkDefault true;

    # Items that must survive a reboot are mapped under /persist.
    preservation = {
      enable = true;
      preserveAt."/persist" = {
        directories = [
          { directory = "/etc/ssh";                            inInitrd = true;  }
          { directory = "/var/lib/systemd";                   inInitrd = false; }
          { directory = "/var/lib/bluetooth";                 inInitrd = false; }
          { directory = "/etc/NetworkManager/system-connections"; inInitrd = false; }
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
          { directory = "/var/lib/fail2ban";                  inInitrd = false; }
          { directory = "/var/lib/crowdsec";                  inInitrd = false; }
          { directory = "/etc/crowdsec";                      inInitrd = false; }
          { directory = "/var/lib/docker";                    inInitrd = false; }
          { directory = "/var/lib/rancher/k3s";               inInitrd = false; }
          { directory = "/etc/rancher";                       inInitrd = false; }
          { directory = "/var/lib/redis-main";                inInitrd = false; }
          { directory = "/var/lib/cups";                      inInitrd = false; }
        ];

        files = [
          # Stable machine-id (journald cursor, systemd-id128)
          "/etc/machine-id"
        ];

        users.${userName} = {
          directories = [
            # Core Configs
            ".config"
            ".local"
            ".ssh"
            ".gnupg"
            ".steam"
            ".var"
            ".wine"
            # Gaming and Applications
            "Games"
            # XDG User Directories
            "Desktop"
            "Documents"
            "Downloads"
            "Music"
            "Pictures"
            "Public"
            "Templates"
            "Videos"
          ];
        };
      };
    };
  };
}
