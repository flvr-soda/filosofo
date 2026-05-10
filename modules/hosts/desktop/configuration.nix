{ self, inputs, ... }: {
  flake.nixosModules.desktopConfiguration = { pkgs, lib, userName, hostPrefix, ... }: {
    imports = [
      self.nixosModules.desktopHardware
      self.nixosModules.base
      # Desktop & Apps
      self.nixosModules.noctaliaDesktop
      self.nixosModules.firefox
      self.nixosModules.vscode
      self.nixosModules.alacritty
      # Development
      self.nixosModules.programming
      self.nixosModules.databases
      self.nixosModules.containers
      self.nixosModules.cybersec
      self.nixosModules.hardware
      # Services (Dual-Role: workstation + background server stack)
      self.nixosModules.arr-stack
      self.nixosModules.multimedia
      self.nixosModules.productivity
      self.nixosModules.gaming
      self.nixosModules.virtualization
      self.nixosModules.kiwix
      self.nixosModules.llm
      self.nixosModules.nextcloud
      self.nixosModules.pihole
      self.nixosModules.tailscale
      self.nixosModules.caddy
      self.nixosModules.jellyfin
      self.nixosModules.navidrome
      self.nixosModules.kavita
    ];

    networking.hostName = "${hostPrefix}-desktop";
    filosofo.hardware = {
      gpu.type = "amd";
      powerProfile = "performance";
    };

    fileSystems."/storage" = {
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
        storageDir = "/storage";
      in
      [ "L+ /home/${userName}/storage - - - - /storage" ]
      ++ map (dir: "d ${storageDir}/${dir} 0755 ${userName} users -") [
        "documents"
        "downloads"
        "pictures"
        "music"
        "videos"
        "templates"
      ];

    home-manager.users.${userName} = { pkgs, ... }: {
      home.packages = with pkgs; [
        # Individual packages not part of a feature module
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

    filosofo.features = {
      desktop.niri.enable = lib.mkDefault true;
      programming.enable = lib.mkDefault true;
      databases.enable = lib.mkDefault true;
      arr-stack.enable = lib.mkDefault true;
      jellyfin.enable = lib.mkDefault true;
      navidrome.enable = lib.mkDefault true;
      kavita.enable = lib.mkDefault true;
      multimedia.enable = lib.mkDefault true;
      productivity.enable = lib.mkDefault true;
      kiwix.enable = lib.mkDefault false;
      llm.enable = lib.mkDefault false;
      nextcloud.enable = lib.mkDefault true;
      pihole.enable = lib.mkDefault false;
      tailscale.enable = lib.mkDefault true;
      caddy.enable = lib.mkDefault true;
    };
  };
}
