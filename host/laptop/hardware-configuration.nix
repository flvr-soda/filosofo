{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "firewire_ohci" "usb_storage" "sd_mod" "sr_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/e41f0052-ec91-4a5e-8c45-fb67de3d4bcf";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-ee955db8-0676-40eb-9baf-7c2bd18f8f60".device = "/dev/disk/by-uuid/ee955db8-0676-40eb-9baf-7c2bd18f8f60";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/F4A3-4ADB";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [ ];
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
