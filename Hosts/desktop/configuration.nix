{ pkgs, ... }:

{
  # Intel CPU configs
  hardware.graphics = {
    extraPackages = with pkgs; [ 
      intel-ocl 
    ];
  };

  # AMD GPU configs
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Desktop specific packages
  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];

  # Jellyfin server
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "isma";
  };

  # Desktop conf
  # Second drive
  fileSystems."/home/isma/storage" = {
    device = "/dev/disk/by-uuid/06bd7b68-b2a4-431a-a48d-0371beed0a71";
    fsType = "btrfs";
    options = [
      "compress=zstd"    # Ahorra mucho espacio en HDDs y reduce el trabajo del cabezal al leer menos datos físicos.
      "noatime"          # Reduce las escrituras de metadatos (menos movimiento del cabezal).
      "autodefrag"       # CRÍTICO para HDDs: mantiene los archivos contiguos para evitar lentitud.
      "nofail"           # Evita que el PC no arranque si el disco falla o se desconecta.
      "space_cache=v2"   # Acelera el montaje y la gestión de espacio libre (estándar moderno).
    ];
  };
}
