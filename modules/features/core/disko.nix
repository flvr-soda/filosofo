# disko.nix — Upgraded for Pure RAM Root (tmpfs) + preservation
{ inputs, lib, ... }:

let
  # The physical Btrfs subvolumes on the SSD.
  # We no longer need an explicit root subvolume here because "/" is in RAM!
  mkBtrfsSubvolumes = {
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

  # Server matching set (no /home)
  mkBtrfsSubvolumesServer = {
    "nix" = {
      mountpoint    = "/nix";
      mountOptions  = [ "compress=zstd" "noatime" ];
    };
    "persist" = {
      mountpoint    = "/persist";
      mountOptions  = [ "compress=zstd" "noatime" ];
    };
  };

  mkEsp = {
    size = "1G";
    type = "EF00";
    content = {
      type       = "filesystem";
      format     = "vfat";
      mountpoint = "/boot";
    };
  };

  mkLuksContent = subvolumes: {
    type    = "luks";
    name    = "crypted";
    extraOpenArgs = [ "--allow-discards" ];
    content = {
      type       = "btrfs";
      extraArgs  = [ "-f" ];
      inherit subvolumes;
    };
  };

  # Shared nodev block that mounts an ultra-fast, clean root partition in RAM
  tmpfsRoot = {
    disko.devices.nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=4G"      # Caps root allocation so it doesn't accidentally eat all your RAM
        "mode=755"
      ];
    };
  };
in
{
  flake.nixosModules.disko = {
    imports = [ inputs.disko.nixosModules.disko ];
    fileSystems."/nix".neededForBoot = true;
    fileSystems."/persist".neededForBoot = true;
  };

  # ── Laptop: Single SSD with RAM Root ──────────────────────────────────────
  flake.lib.mkDiskoConfigLaptop = { device }: 
    lib.recursiveUpdate tmpfsRoot {
      disko.devices.disk.main = {
        inherit device;
        type    = "disk";
        content = {
          type       = "gpt";
          partitions = {
            ESP  = mkEsp;
            luks = {
              size    = "100%";
              content = mkLuksContent mkBtrfsSubvolumes;
            };
          };
        };
      };
    };

  # ── Desktop: OS SSD + Mass Storage with RAM Root ──────────────────────────
  flake.lib.mkDiskoConfigDesktop = { systemDevice, storageDevice }:
    lib.recursiveUpdate tmpfsRoot {
      disko.devices.disk = {
        system = {
          device  = systemDevice;
          type    = "disk";
          content = {
            type       = "gpt";
            partitions = {
              ESP  = mkEsp;
              luks = {
                size    = "100%";
                content = mkLuksContent mkBtrfsSubvolumes // { name = "crypted-system"; };
              };
            };
          };
        };
        storage = {
          device  = storageDevice;
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

  # ── Server Blueprint: OS SSD + Storage Array with RAM Root ────────────────
  flake.lib.mkDiskoConfigServer = { systemDevice, raidDevices }:
    let
      raidPartitions = builtins.map (dev: "${dev}-part1") raidDevices;
      raidArgs = [ "-f" "--data" "raid1c3" "--metadata" "raid1c3" ] ++ raidPartitions;
    in
    lib.recursiveUpdate tmpfsRoot {
      disko.devices.disk =
        {
          system = {
            device  = systemDevice;
            type    = "disk";
            content = {
              type       = "gpt";
              partitions = {
                ESP  = mkEsp;
                luks = {
                  size    = "100%";
                  content = mkLuksContent mkBtrfsSubvolumesServer // { name = "crypted-system"; };
                };
              };
            };
          };
        }
        //
        builtins.listToAttrs (
          lib.imap1 (i: dev: {
            name  = "raid${builtins.toString i}";
            value = {
              device  = dev;
              type    = "disk";
              content = {
                type       = "gpt";
                partitions.data = {
                  size    = "100%";
                } // lib.optionalAttrs (i == 1) {
                  content = {
                    type         = "btrfs";
                    extraArgs    = raidArgs;
                    mountpoint   = "/storage";
                    mountOptions = [
                      "compress=zstd" "noatime" "autodefrag" "space_cache=v2"
                    ];
                  };
                };
              };
            };
          }) raidDevices
        );
    };
}
