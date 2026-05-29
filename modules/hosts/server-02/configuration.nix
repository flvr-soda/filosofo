# server-02/configuration.nix — Compute/Containers node
{ self, inputs, ... }: {
  flake.nixosModules.server02Configuration = { lib, pkgs, ... }: {
    imports =
      [
        self.nixosModules.core
        self.nixosModules.databases
        self.nixosModules.homelab
        self.nixosModules.netbird
        self.nixosModules.virtualization
        ./_disko.nix
      ];

    networking.hostName = "server-02";

    filosofo.hardware = {
      gpu.type     = "none";
      powerProfile = "balanced";
    };

    filosofo.features = {
      databases.enable          = lib.mkDefault true;
      homelab.full-stack.enable = lib.mkDefault true;
      arr-stack.enable          = lib.mkDefault true;
      virtualization.enable     = lib.mkDefault true;
      netbird = {
        enable             = lib.mkDefault true;
        useRoutingFeatures = lib.mkDefault "server";
      };
    };

    # Software-only hardware stubs (avoids needing a hardware-configuration.nix)
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    boot.loader.systemd-boot.enable = lib.mkDefault true;
    boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

    # Enables serial console ttyS0 for out-of-band crash recovery on headless hardware.
    boot.kernelParams = lib.mkAfter [ "console=ttyS0,115200" ];

    services.openssh.settings.PermitRootLogin = lib.mkForce "prohibit-password";
  };
}
