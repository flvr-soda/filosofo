{ self, inputs, ... }: {
  flake.nixosModules.plasma = { pkgs, lib, userName, ... }: {
    services.xserver.enable = true;
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    services.desktopManager.plasma6.enable = true;
    services.displayManager.autoLogin = {
      enable = true;
      user = userName;
    };

    services.xserver.desktopManager.xterm.enable = false;
    services.xserver.excludePackages = [ pkgs.xterm ];

    environment.plasma6.excludePackages = with pkgs; [
      kdePackages.elisa
      kdePackages.khelpcenter
      kdePackages.kate
      kdePackages.kwalletmanager
      kdePackages.kwallet-pam
      kdePackages.kwallet
    ];

    security.pam.services.login.kwallet.enable = lib.mkForce false;
    security.pam.services.sddm.kwallet.enable = lib.mkForce false;
  };
}
