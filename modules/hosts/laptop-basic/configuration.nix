# laptop-basic/configuration.nix — Non-power user daily driver
{ self, inputs, ... }: {
  flake.nixosModules.laptopBasicConfiguration = { lib, pkgs, ... }: {
    imports =
      [
        self.nixosModules.laptopBasicHardware
        self.nixosModules.core
        self.nixosModules.ui
        self.nixosModules.browsers
        self.nixosModules.media
        self.nixosModules.productivity
        self.nixosModules.netbird
        ./_disko.nix
      ];

    networking.hostName = "laptop-basic";

    filosofo.hardware = {
      gpu.type     = "intel";
      powerProfile = "powersave";
    };

    filosofo.features = {
      desktop.niri.enable             = lib.mkDefault true;
      desktop.autologin.enable        = lib.mkDefault true;
      browsers.enable                 = lib.mkDefault true;
      media.enable                    = lib.mkDefault true;
      productivity.enable             = lib.mkDefault true;
      netbird.enable                  = lib.mkDefault true;
    };
  };
}
