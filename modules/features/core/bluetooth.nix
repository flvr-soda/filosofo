# core/bluetooth.nix — Core bluetooth hardware support
{ lib, ... }: {
  flake.nixosModules.bluetooth = { config, ... }: {
    options.filosofo.core.bluetooth = {
      enable = lib.mkEnableOption "Enable core bluetooth hardware support";
    };

    config = lib.mkIf config.filosofo.core.bluetooth.enable {
      hardware.bluetooth.enable      = true;
      hardware.bluetooth.powerOnBoot = true;
    };
  };
}
