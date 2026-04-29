{ pkgs, userName, ... }:
let
  mods = import ../../modules/system;
in {
  imports = [
    mods.system-base
    mods.graphical
    mods.gaming
    mods.development
    mods.secrets
    ./hardware-configuration.nix
  ];

  networking.hostName = "filosofo-desktop";

  hardware.graphics = {
    extraPackages = with pkgs; [
      intel-ocl
    ];
  };

  services.xserver.videoDrivers = [ "amdgpu" ];

  fileSystems."/home/${userName}/storage" = {
    device = "/dev/disk/by-uuid/06bd7b68-b2a4-431a-a48d-0371beed0a71";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "noatime"
      "autodefrag"
      "nofail"
      "space_cache=v2"
    ];
  };
}
