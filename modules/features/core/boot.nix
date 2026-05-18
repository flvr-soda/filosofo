{ self, inputs, ... }: {
  flake.nixosModules.boot = { pkgs, ... }: {
    boot = {
      kernelPackages = pkgs.linuxPackages_latest;
      loader.systemd-boot.enable = true;
      loader.systemd-boot.configurationLimit = 5;
      loader.efi.canTouchEfiVariables = true;
      loader.timeout = 3;
      consoleLogLevel = 0;
      initrd.verbose = false;
      kernelParams = [
        "splash"
        "quiet"
        "boot.shell_on_fail"
        "loglevel=3"
        "rd.systemd.show_status=false"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
      ];

      kernel.sysctl = {
        "kernel.kptr_restrict" = 1;
        "kernel.perf_event_paranoid" = 3;
        # Aggressively swap idle pages to ZRAM to maximize hot RAM availability
        "vm.swappiness" = 180;
        # Disable sequential read-ahead swap pages to eliminate CPU ZRAM overhead
        "vm.page-cluster" = 0;
        # Keep file system metadata in memory longer for faster directory listing
        "vm.vfs_cache_pressure" = 50;
      };
      tmp.cleanOnBoot = true;
      tmp.useTmpfs = true;
    };

    security = {
      protectKernelImage = true;
      lockKernelModules = false;
      apparmor = {
        enable = true;
        killUnconfinedConfinables = true;
        packages = with pkgs; [ apparmor-utils apparmor-profiles ];
      };
    };
    # Enable ZRAM swap to prevent OOM crashes during heavy Nix builds/compilations
    # and to complement the tmpfs root used for impermanence.
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50;
      priority = 100;
    };
    swapDevices = [];
  };
}
