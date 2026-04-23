{ pkgs, ... }: {
  imports = [
    ../default.nix
    ./hardware-configuration.nix
  ];

  hardware.graphics = {
    extraPackages = with pkgs; [
      intel-ocl
    ];
  };

  services.xserver.videoDrivers = [ "amdgpu" ];

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };
  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      WLR_NO_HARDWARE_CURSORS = "1";
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    };
  };

  fileSystems."/home/isma/storage" = {
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
