{ self, inputs, ... }: {
  flake.nixosModules.desktopConfiguration = { pkgs, lib, userName, hostPrefix, ... }: {
    imports =
      [
        self.nixosModules.desktopHardware
        self.nixosModules.base
      ]
      ++ import ./_role-imports.nix { inherit self; }
      ++ [ (import ./_role-defaults.nix) ];

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
  };
}
