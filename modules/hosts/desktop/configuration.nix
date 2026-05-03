{ self, inputs, ... }: {
  flake.nixosModules.desktopConfiguration = { pkgs, lib, userName, hostPrefix, ... }: {
    imports = [
      self.nixosModules.desktopHardware
      # Core
      self.nixosModules.system
      self.nixosModules.boot
      self.nixosModules.nixConfig
      self.nixosModules.networking
      self.nixosModules.security
      self.nixosModules.locale
      self.nixosModules.ssh
      self.nixosModules.users
      self.nixosModules.secrets
      self.nixosModules.shared
      # Desktop & Apps
      self.nixosModules.plasma
      self.nixosModules.firefox
      self.nixosModules.vscode
      self.nixosModules.alacritty
      # Development
      self.nixosModules.programming
      self.nixosModules.databases
      self.nixosModules.containers
      self.nixosModules.cybersec
      self.nixosModules.hardware
      # Services
      self.nixosModules.jellyfin
      self.nixosModules.gaming
      self.nixosModules.shell
      self.nixosModules.virtualization
    ];

    networking.hostName = "${hostPrefix}-desktop";

    hardware.graphics = {
      extraPackages = with pkgs; [
        intel-ocl
      ];
    };

    services.xserver.videoDrivers = [ "amdgpu" ];
    hardware.amdgpu.opencl.enable = true;

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

    systemd.tmpfiles.rules =
      let
        storageDir = "/home/${userName}/storage";
      in
      map (dir: "d ${storageDir}/${dir} 0755 ${userName} users -") [
        "documents"
        "downloads"
        "pictures"
        "music"
        "videos"
        "templates"
        "media" # Jellyfin library root
      ];

    home-manager.users.${userName} = { pkgs, ... }: {
      home.packages = with pkgs; [
        qbittorrent-enhanced
        vlc
        imagemagick
        ffmpeg
        onlyoffice-desktopeditors
      ];

      xdg.userDirs = {
        enable = true;
        createDirectories = false;
        documents = "/home/${userName}/storage/documents";
        download = "/home/${userName}/storage/downloads";
        pictures = "/home/${userName}/storage/pictures";
        music = "/home/${userName}/storage/music";
        videos = "/home/${userName}/storage/videos";
        templates = "/home/${userName}/storage/templates";
        desktop = "/home/${userName}/Desktop";
        publicShare = "/home/${userName}/Public";
        setSessionVariables = true;
      };
    };
  };
}
