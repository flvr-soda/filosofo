# Flake-parts module defining the NixOS configuration for the 'desktop' host.
# Following the Dendritic pattern, this file natively exports `flake.nixosConfigurations.desktop`.
{ self, inputs, userName, userFullName, userEmail, gitName, stateVersion, timeZone, defaultLocale, extraLocale, keyMap, hostPrefix, ... }: {
  flake.nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs self userName userFullName userEmail gitName stateVersion timeZone defaultLocale extraLocale keyMap hostPrefix; };
    modules = [
      # Hardware specific configuration
      ./hardware-configuration.nix
      
      # Reusable Dendritic modules exported by our flake
      self.nixosModules.base
      self.nixosModules.users
      self.nixosModules.graphical
      self.nixosModules.development
      self.nixosModules.gaming
      self.nixosModules.secrets
      self.nixosModules.shared
      self.nixosModules.jellyfin
      self.nixosModules.shell
      self.nixosModules.virtualization
      
      # Inline module for host-specific configuration
      ({ pkgs, userName, ... }: {
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

        # Pre-create all XDG user directories on the storage HDD at boot,
        # before the user session starts, so they are guaranteed to exist
        # when xdg-user-dirs reads its config on first login.
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
          ];

          # Redirect standard XDG user directories to the storage HDD.
          # Applications that respect XDG (file pickers, browsers, LibreOffice, etc.)
          # will automatically read and write to these paths.
          xdg.userDirs = {
            enable = true;
            createDirectories = false; # Handled declaratively by systemd.tmpfiles above
            documents = "/home/${userName}/storage/documents";
            download = "/home/${userName}/storage/downloads";
            pictures = "/home/${userName}/storage/pictures";
            music = "/home/${userName}/storage/music";
            videos = "/home/${userName}/storage/videos";
            templates = "/home/${userName}/storage/templates";
            # Keep Desktop and publicShare on the SSD — they're ephemeral/unused
            desktop = "/home/${userName}/Desktop";
            publicShare = "/home/${userName}/Public";
            setSessionVariables = true;
          };
        };
      })
    ];
  };
}
