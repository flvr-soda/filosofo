{ self, inputs, ... }: {
  flake.nixosModules.serverConfiguration = { lib, userName, hostPrefix, ... }: {
    imports = [
      self.nixosModules.serverHardware
      self.nixosModules.base
      # Services — server runs the full stack
      self.nixosModules.arr-stack
      self.nixosModules.databases
      self.nixosModules.multimedia
      self.nixosModules.kiwix
      self.nixosModules.llm
      self.nixosModules.nextcloud
      self.nixosModules.pihole
      self.nixosModules.tailscale
      self.nixosModules.caddy
      self.nixosModules.virtualization
    ];

    networking.hostName = "${hostPrefix}-server";

    # Server-specific: serial console for headless access
    boot.kernelParams = lib.mkAfter [ "console=ttyS0,115200" ];

    # Harden SSH on the server — no root login
    services.openssh.settings.PermitRootLogin = lib.mkForce "no";

    # Resource limits for resource-hungry services
    systemd.services.ollama.serviceConfig = lib.mkIf false {
      MemoryLimit = "8G";
      CPUQuota = "400%";
    };

    filosofo.features = {
      arr-stack.enable = lib.mkDefault true;
      databases.enable = lib.mkDefault true;
      multimedia.enable = lib.mkDefault true;
      kiwix.enable = lib.mkDefault true;
      llm.enable = lib.mkDefault true;
      nextcloud.enable = lib.mkDefault true;
      pihole.enable = lib.mkDefault true;
      tailscale = {
        enable = lib.mkDefault true;
        useRoutingFeatures = lib.mkDefault "server";
        headlessJoin = lib.mkDefault true; # Server joins tailnet automatically
      };
      caddy.enable = lib.mkDefault true;
    };
  };
}
