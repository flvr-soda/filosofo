{ self, inputs, ... }: {
  flake.nixosModules.laptopConfiguration = { lib, pkgs, userName, hostPrefix, ... }: {
    imports =
      [
        self.nixosModules.laptopHardware
        self.nixosModules.base
      ]
      ++ import ./_role-imports.nix { inherit self; }
      ++ [ (import ./_role-defaults.nix) ];

    networking.hostName = "${hostPrefix}-laptop";

    environment.systemPackages = with pkgs; [
      brightnessctl
    ];
  };
}
