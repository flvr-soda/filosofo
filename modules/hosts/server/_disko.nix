# modules/hosts/server/disko.nix — Server Disko Layout
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
        device  = "/dev/disk/by-id/ata-PUT-YOUR-SSD-ID-HERE";
        type    = "disk";
        content = {
          type       = "gpt";
          partitions = {
            ESP = {
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
      # We define a RAID1 array across our HDD pool for massive storage
      raid1 = {
        device  = "/dev/disk/by-id/ata-HDD-1-ID";
        type    = "disk";
        content = {
          type       = "gpt";
          partitions.data = {
            size = "100%";
            content = {
              type         = "btrfs";
              extraArgs    = [ "-f" "--data" "raid1" "--metadata" "raid1" "/dev/disk/by-id/ata-HDD-1-ID-part1" "/dev/disk/by-id/ata-HDD-2-ID-part1" "/dev/disk/by-id/ata-HDD-3-ID-part1" ];
              mountpoint   = "/storage";
              mountOptions = [
                "compress=zstd" "noatime" "autodefrag" "space_cache=v2"
              ];
            };
          };
        };
      };
      raid2 = {
        device  = "/dev/disk/by-id/ata-HDD-2-ID";
        type    = "disk";
        content = {
          type       = "gpt";
          partitions.data = {
            size = "100%";
          };
        };
      };
      raid3 = {
        device  = "/dev/disk/by-id/ata-HDD-3-ID";
        type    = "disk";
        content = {
          type       = "gpt";
          partitions.data = {
            size = "100%";
          };
        };
      };
    };
  };
}
