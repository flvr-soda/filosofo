# server/configuration.nix — Headless Homelab Server
{ self, inputs, ... }: {
  flake.nixosModules.serverConfiguration = { lib, pkgs, hostPrefix, ... }: {
    imports =
      [
        self.nixosModules.serverHardware
        self.nixosModules.core
        self.nixosModules.databases
        self.nixosModules.homelab
        self.nixosModules.tailscale
        self.nixosModules.virtualization
        self.nixosModules.ollama
        self.nixosModules.open-webui
        self.nixosModules.opencode
        self.nixosModules.searxng
        # Disko layout: OS SSD (BTRFS-on-LUKS) + RAID5 storage pool
        (self.lib.mkDiskoConfigServer {
          systemDevice = "/dev/disk/by-id/ata-PUT-YOUR-SSD-ID-HERE";
          raidDevices  = [
            "/dev/disk/by-id/ata-HDD-1-ID"
            "/dev/disk/by-id/ata-HDD-2-ID"
            "/dev/disk/by-id/ata-HDD-3-ID"
            # "/dev/disk/by-id/ata-HDD-4-ID"  # uncomment for 4-drive RAID5
          ];
        })
      ];

    networking.hostName = "${hostPrefix}-server";

    # ── Hardware profile: no GPU ─────────────────────────────────────────────
    filosofo.hardware = {
      gpu.type     = "none";
      powerProfile = "balanced";
    };

    filosofo.features = {
      databases.enable          = lib.mkDefault true;
      arr-stack.enable          = lib.mkDefault true;
      virtualization.enable     = lib.mkDefault true;
      tailscale = {
        enable             = lib.mkDefault true;
        useRoutingFeatures = lib.mkDefault "server";
        headlessJoin       = lib.mkDefault true;
      };
    };

    filosofo.services.searxng.enable     = lib.mkDefault true;

    # ── AI Services Configuration ───────────────────────────────────────────
    # AI suite active on server in CPU mode (no AMD GPU on server)
    filosofo.services.ai = {
      local-inference = lib.mkDefault true;
      models          = lib.mkDefault [ "llama3.1" "llama3.2" ];
    };

    # ── Serial console for headless crash recovery ────────────────────────────
    boot.kernelParams = lib.mkAfter [ "console=ttyS0,115200" ];

    # ── SSH hardening: no root login ──────────────────────────────────────────
    services.openssh.settings.PermitRootLogin = lib.mkForce "no";

    # ── Resource bounds for CPU-only Ollama inference ─────────────────────────
    systemd.services.ollama.serviceConfig = {
      MemoryMax = "12G";
      CPUQuota  = "600%"; # allow up to 6 logical cores
    };
  };
}