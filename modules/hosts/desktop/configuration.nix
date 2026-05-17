# desktop/configuration.nix — AMD Desktop Workstation
{ self, inputs, ... }: {
  flake.nixosModules.desktopConfiguration = { lib, pkgs, userName, hostPrefix, ... }: {
    imports =
      [
        self.nixosModules.desktopHardware
        self.nixosModules.core
        self.nixosModules.ui
        self.nixosModules.dev-tools
        self.nixosModules.toolchains
        self.nixosModules.engineering
        self.nixosModules.gaming
        self.nixosModules.browsers
        self.nixosModules.media
        self.nixosModules.productivity
        self.nixosModules.database-clients
        self.nixosModules.databases
        self.nixosModules.tailscale
        self.nixosModules.virtualization
        self.nixosModules.homelab
        self.nixosModules.ollama
        self.nixosModules.open-webui
        self.nixosModules.opencode
        self.nixosModules.searxng
        # Disko layout: OS SSD (BTRFS-on-LUKS) + mass storage HDD
        (self.lib.mkDiskoConfigDesktop {
          systemDevice  = "/dev/disk/by-id/nvme-NVME_256GB_SSD_C2024101001028";
          storageDevice = "/dev/disk/by-uuid/06bd7b68-b2a4-431a-a48d-0371beed0a71";
        })
      ];

    networking.hostName = "${hostPrefix}-desktop";

    # ── Hardware profile ─────────────────────────────────────────────────────
    filosofo.hardware = {
      gpu.type     = "amd";
      powerProfile = "performance";
    };

    # ── Features Toggles ────────────────────────────────────────────────────
    filosofo.features = {
      desktop.niri.enable             = lib.mkDefault true;
      dev-tools.enable                = lib.mkDefault true;
      toolchains.enable               = lib.mkDefault true;
      engineering.enable              = lib.mkDefault true;
      databases.enable                = lib.mkDefault true;
      database-clients.enable         = lib.mkDefault true;
      browsers.enable                 = lib.mkDefault true;
      media.enable                    = lib.mkDefault true;
      productivity.enable             = lib.mkDefault true;
      gaming.enable                   = lib.mkDefault true;
      arr-stack.enable                = lib.mkDefault true;
      virtualization.enable           = lib.mkDefault true;
      tailscale.enable                = lib.mkDefault true;
    };
    filosofo.services.searxng.enable     = lib.mkDefault true;
    
    filosofo.services.ai = {
      local-inference = lib.mkDefault true;
      forceCpu = true; # Bypasses ROCm to prevent crashes on the legacy RX 470
    };

    # ── User Directories ────────────────────────────────────────────────────
    home-manager.users.${userName} = { ... }: {
      xdg.userDirs = {
        enable            = true;
        createDirectories = true;
      };
    };

    # ── /storage user directory bind mount ───────────────────────────────────
    fileSystems."/home/${userName}/storage" = {
      device = "/storage";
      fsType = "none";
      options = [ "bind" ];
      depends = [ "/storage" ];
    };

    # ── Printing (host-specific: Samsung ML-1660 via USB) ──────────────────
    services.printing.enable = true;
    services.printing.drivers = [ pkgs.splix pkgs.samsung-unified-linux-driver ];
    services.ipp-usb.enable = true;
    hardware.printers.ensurePrinters = [
      {
        name = "ML-1660";
        deviceUri = "usb://Samsung/ML-1660%20Series?serial=Z508BKBZ701777X";
        model = "samsung/ml1660.ppd";
      }
    ];
  };
}
