{ inputs, ... }: {
  # Disko configuration for declarative partitioning and LUKS encryption
  # This module provides a standard Btrfs-on-LUKS layout.
  
  flake.nixosModules.disko = {
    imports = [ inputs.disko.nixosModules.disko ];
  };

  # Standard Btrfs-on-LUKS layout function
  flake.lib.mkDiskoConfig = { device}: {
    disko.devices = {
      disk.main = {
        inherit device;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                # passwordFile = "/tmp/secret.key"; # Usually set during installation
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
