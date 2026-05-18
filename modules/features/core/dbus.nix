# core/dbus.nix — Core DBus IPC system daemon
{ lib, ... }: {
  flake.nixosModules.dbus = { config, ... }: {
    options.filosofo.core.dbus = {
      enable = lib.mkEnableOption "Enable core DBus service";
    };

    config = lib.mkIf config.filosofo.core.dbus.enable {
      services.dbus.enable = true;
    };
  };
}
