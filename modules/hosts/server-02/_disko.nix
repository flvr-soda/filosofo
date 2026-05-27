# modules/hosts/server-02/_disko.nix — Server Disko Layout
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
            swap = {
              size = "16G";
              content = {
                type = "swap";
                priority = 10;
                randomEncryption = true;
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
    };
  };
}
