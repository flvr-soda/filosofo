{ self, inputs, ... }: {
  flake.nixosModules.hardware = { pkgs, userName, ... }: {
    # NixOS System-Level Configuration
    users.users.${userName}.extraGroups = [ "dialout" "tty" ];
    services.udev.packages = [ pkgs.arduino-ide ];

    # Home Manager User-Level Configuration
    home-manager.users.${userName} = { pkgs, ... }: {
      home.packages = with pkgs; [
        arduino-ide
        arduino-cli
        kicad
      ];
    };
  };
}
