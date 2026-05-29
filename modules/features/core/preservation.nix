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
          { directory = "/etc/ssh";                               inInitrd = true;  }
          { directory = "/etc/NetworkManager/system-connections"; inInitrd = false; }
          { directory = "/etc/crowdsec";                          inInitrd = false; }
          { directory = "/etc/rancher";                           inInitrd = false; }
          { directory = "/var/lib";                               inInitrd = false; }
          { directory = "/var/log";                               inInitrd = false; }
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
            ".cache/noctalia"
            # Gaming and Applications
            "Games"
            # XDG User Directories
            "Development"
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
