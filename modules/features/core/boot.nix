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
        "boot.shell_on_fail"
        "loglevel=3"
        "rd.systemd.show_status=false"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
      ];

      # ── Security Hardening ──────────────────────────────────────────────
      kernel.sysctl = {
        "kernel.kptr_restrict" = 1;
        "kernel.perf_event_paranoid" = 3;
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
    # Swap is explicitly prohibited — impermanence uses BTRFS compression instead.
    zramSwap.enable = false;
    swapDevices = [];
  };
}
