{
  pkgs,
  inputs,
  lib,
  isDesktop,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../commonSystem.nix
  ];
  services.desktopManager.gnome.enable = true;
}
