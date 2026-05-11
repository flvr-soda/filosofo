{ self, ... }: {
  # Dolphin File Manager — Atomic App Module
  # Separated from the WM configuration to maintain the dendritic pattern.
  
  flake.nixosModules.dolphin = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      kdePackages.dolphin
      kdePackages.kio-extras
      kdePackages.ffmpegthumbs
      # Qt styling support for Wayland
      kdePackages.qtwayland
      kdePackages.qtsvg
    ];

    # Ensure thumbnail services are running
    services.tumbler.enable = true;
  };
}
