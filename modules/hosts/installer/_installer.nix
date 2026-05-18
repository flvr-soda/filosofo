# modules/hosts/installer/_installer.nix — Custom installer configuration
{ pkgs, inputs, ... }: {
  # target platform
  nixpkgs.hostPlatform = "x86_64-linux";

  # Enable Flakes and nix-commands by default in the live environment
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Configure NetworkManager (providing nmtui) and disable wpa_supplicant conflicts
  networking.networkmanager.enable = true;
  networking.wireless.enable       = false;

  # Pre-load critical offline installation utilities
  environment.systemPackages = with pkgs; [
    git
    cryptsetup
    wipefs
    parted
    btrfs-progs
    # Include Disko CLI directly so 'disko' is an offline command
    inputs.disko.packages.x86_64-linux.disko
  ];

  # Console keyboard layout and font
  console = {
    font   = "Lat2-Terminus16";
    keyMap = "us";
  };
}
