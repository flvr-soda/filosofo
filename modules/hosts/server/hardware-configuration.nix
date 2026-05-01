{ lib, ... }: {
  # Replace these defaults with the real generated hardware config on the server:
  # sudo nixos-generate-config --show-hardware-config > host/server/hardware-configuration.nix
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  fileSystems."/" = lib.mkDefault {
    device = "none";
    fsType = "tmpfs";
  };
}
