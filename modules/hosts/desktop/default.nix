# Flake-parts module defining the NixOS configuration for the 'desktop' host.
# Following the Dendritic pattern, this file natively exports `flake.nixosConfigurations.desktop`.
{ self, inputs, userName, userFullName, userEmail, gitName, stateVersion, ... }: {
  flake.nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs self userName userFullName userEmail gitName stateVersion; };
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
      
      # Inline module for host-specific configuration
      ({ pkgs, userName, ... }: {
        networking.hostName = "filosofo-desktop";

        hardware.graphics = {
          extraPackages = with pkgs; [
            intel-ocl
          ];
        };

        services.xserver.videoDrivers = ["amdgpu"];

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

        home-manager.users.${userName} = {pkgs, ...}: {
          home.packages = with pkgs; [
            qbittorrent-enhanced
            vlc
            texstudio
            miktex
            imagemagick
            ffmpeg
          ];
        };
      })
    ];
  };
}
