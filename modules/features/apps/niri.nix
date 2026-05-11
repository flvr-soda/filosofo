{ self, ... }: {
  # Niri Window Manager — Refactored to use wrapped approach from nixconf
  
  flake.nixosModules.niri = { config, pkgs, lib, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
    };

    environment.systemPackages = with pkgs; [
      alacritty
      alsa-utils
      awww
      brightnessctl
      grim
      pavucontrol
      slurp
      wl-clipboard
      xwayland-satellite
    ];
  };
}
