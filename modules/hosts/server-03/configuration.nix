# server-03/configuration.nix — AI Inference node
{ self, inputs, ... }: {
  flake.nixosModules.server03Configuration = { lib, pkgs, ... }: {
    imports =
      [
        self.nixosModules.core
        self.nixosModules.tailscale
        self.nixosModules.virtualization
        self.nixosModules.ollama
        self.nixosModules.open-webui
        self.nixosModules.opencode
        self.nixosModules.searxng
        ./_disko.nix
      ];

    networking.hostName = "server-03";

    filosofo.hardware = {
      gpu.type     = "amd"; # Placeholder for future GPU passthrough
      powerProfile = "performance";
    };

    filosofo.features = {
      virtualization.enable     = lib.mkDefault true;
      tailscale = {
        enable             = lib.mkDefault true;
        useRoutingFeatures = lib.mkDefault "server";
        headlessJoin       = lib.mkDefault true;
      };
    };

    filosofo.services.searxng.enable     = lib.mkDefault true;

    filosofo.services.ai = {
      local-inference = lib.mkDefault true;
      models          = lib.mkDefault [ "llama3.1" "llama3.2" ];
    };

    # Software-only hardware stubs (avoids needing a hardware-configuration.nix)
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    boot.loader.systemd-boot.enable = lib.mkDefault true;
    boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

    # Enables serial console ttyS0 for out-of-band crash recovery on headless hardware.
    boot.kernelParams = lib.mkAfter [ "console=ttyS0,115200" ];

    services.openssh.settings.PermitRootLogin = lib.mkForce "prohibit-password";

    # Limits resource usage of Ollama to prevent inference from starving host operations.
    systemd.services.ollama.serviceConfig = {
      MemoryMax = "12G";
      CPUQuota  = "600%"; # allow up to 6 logical cores
    };
  };
}
