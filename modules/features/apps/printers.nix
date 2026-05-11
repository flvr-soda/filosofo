{ self, ... }: {
  # Printer Management GUI — Atomic App Module
  
  flake.nixosModules.printers-gui = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      system-config-printer
    ];

    # Ensure CUPS service is enabled (common requirement for the GUI)
    services.printing.enable = true;
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
