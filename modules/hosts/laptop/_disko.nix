# modules/hosts/laptop/disko.nix — Laptop Disko Layout
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
    disk.main = {
      device  = "/dev/disk/by-id/ata-addlink_SATA_SSD_2023080802000521";
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
              name    = "crypted";
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
  };
}
