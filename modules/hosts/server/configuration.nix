{ self, inputs, ... }: {
  flake.nixosModules.serverConfiguration = { lib, userName, hostPrefix, ... }: {
    imports =
      [
        self.nixosModules.serverHardware
        self.nixosModules.base
      ]
      ++ import ./_role-imports.nix { inherit self; }
      ++ [ (import ./_role-defaults.nix) ];

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
  };
}
