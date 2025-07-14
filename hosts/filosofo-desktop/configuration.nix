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
  # Additional desktop-specific customizations can go below
  boot.kernelParams = lib.mkForce ["amdgpu.dc=1"];
}
