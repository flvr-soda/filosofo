{ self, inputs, ... }: {
  flake.nixosModules.boot = { pkgs, ... }: {
    boot = {
      kernelPackages = pkgs.linuxPackages_latest;
      loader.systemd-boot.enable = true;
      loader.systemd-boot.consoleMode = "max";
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
        # Disables cluster readahead, which is ideal for zram setups.
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
    # Enable ZRAM swap to prevent OOM crashes 
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50;
      priority = 100;
    };

    # Limit shutdown delays caused by hung services on ephemeral sessions
    systemd.settings.Manager = {
      DefaultTimeoutStartSec = "15s";
      DefaultTimeoutStopSec = "10s";
    };

    # Prevent boot journals from accumulating endlessly and filling up persistent storage
    services.journald.extraConfig = ''
      SystemMaxUse=100M
      MaxRetentionSec=1month
    '';
  };
}
