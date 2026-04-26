{pkgs, ... }:
let
  mods = import ../modules;
in {
  imports = [
    mods.system-base
    mods.graphical
    mods.gaming
    mods.development
    ./hardware-configuration.nix
  ];

  networking.hostName = "filosofo-laptop";

  # Keep laptop tuned for portable use.
  services.tlp.enable = true;
  services.power-profiles-daemon.enable = false;
  powerManagement.powertop.enable = true;

  environment.systemPackages = with pkgs; [
    brightnessctl
  ];
}
