# modules/hosts/desktop/disko.nix — Desktop Disko Layout
{ inputs, ... }: {
  imports = [ inputs.disko.nixosModules.disko ];

  fileSystems."/nix".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;

  disko.devices = {
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=4G"
        "mode=755"
      ];
    };
    disk = {
      system = {
        device  = "/dev/disk/by-id/nvme-NVME_256GB_SSD_C2024101001028";
        type    = "disk";
        content = {
          type       = "gpt";
          partitions = {
            ESP  = {
              size = "1G";
              type = "EF00";
              content = {
                type       = "filesystem";
                format     = "vfat";
                mountpoint = "/boot";
              };
            };
            luks = {
              size    = "100%";
              content = {
                type    = "luks";
                name    = "crypted-system";
                extraOpenArgs = [ "--allow-discards" ];
                content = {
                  type       = "btrfs";
                  extraArgs  = [ "-f" ];
                  subvolumes = {
                    "home" = {
                      mountpoint    = "/home";
                      mountOptions  = [ "compress=zstd" "noatime" ];
                    };
                    "nix" = {
                      mountpoint    = "/nix";
                      mountOptions  = [ "compress=zstd" "noatime" ];
                    };
                    "persist" = {
                      mountpoint    = "/persist";
                      mountOptions  = [ "compress=zstd" "noatime" ];
                    };
                  };
                };
              };
            };
          };
        };
      };
      storage = {
        device  = "/dev/disk/by-id/ata-GB0500EAFYL_WCASY9098253";
        type    = "disk";
        content = {
          type       = "gpt";
          partitions.luks = {
            size    = "100%";
            content = {
              type = "luks";
              name = "crypted-storage";
              content = {
                type         = "filesystem";
                format       = "btrfs";
                mountpoint   = "/storage";
                mountOptions = [
                  "compress=zstd" "noatime" "autodefrag" "space_cache=v2"
                ];
              };
            };
          };
        };
      };
    };
  };
}
