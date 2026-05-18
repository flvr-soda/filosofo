# hardware.nix — GPU and Power management
{ lib, ... }: {
  flake.nixosModules.hardware = { config, pkgs, ... }: {
    options.filosofo.hardware = {
      gpu.type = lib.mkOption {
        type = lib.types.enum [ "none" "amd" "nvidia" "intel" ];
        default = "none";
        description = "Enable GPU-specific drivers and tuning.";
      };
      powerProfile = lib.mkOption {
        type = lib.types.enum [ "performance" "balanced" "powersave" ];
        default = "balanced";
        description = "System power profile.";
      };
    };

    config = lib.mkMerge [
      (lib.mkIf (config.filosofo.hardware.gpu.type == "amd") {
        services.xserver.videoDrivers = [ "amdgpu" ];

        hardware.amdgpu = {
          opencl.enable  = true;
        };
        # Load amdgpu during initrd for early graphics initialization
        boot.initrd.kernelModules = [ "amdgpu" ];

        hardware.graphics = {
          enable       = true;
          enable32Bit  = true;
          extraPackages = with pkgs; [
            rocmPackages.clr
            rocmPackages.clr.icd
            libvdpau-va-gl
            libva-utils
          ];
        };

        environment.sessionVariables = {
          LIBVA_DRIVER_NAME   = "radeonsi";
          VDPAU_DRIVER        = "radeonsi";
          ROC_ENABLE_PRE_VEGA = "1";   # Widen ROCm device support
        };

        environment.systemPackages = with pkgs; [
          rocmPackages.rocm-smi
          rocmPackages.rocminfo
          clinfo
          vulkan-tools
        ];
      })

      (lib.mkIf (config.filosofo.hardware.gpu.type == "intel") {
        services.xserver.videoDrivers = [ "modesetting" ];
        # Load i915 during initrd for early graphics initialization
        boot.initrd.kernelModules = [ "i915" ];
        # Enable fastboot for Intel to avoid display flicker
        boot.kernelParams = [ "i915.fastboot=1" ];

        hardware.graphics = {
          enable       = true;
          enable32Bit  = true;
          extraPackages = with pkgs; [
            intel-media-driver
            intel-vaapi-driver
            libva-vdpau-driver
            libvdpau-va-gl
          ];
        };

        environment.sessionVariables = {
          LIBVA_DRIVER_NAME = "iHD";
        };
      })

      {
        # thermald is Intel-only; skip on AMD hosts
        services.thermald.enable   = lib.mkDefault (config.filosofo.hardware.gpu.type != "amd");
        services.irqbalance.enable = lib.mkDefault true;
        services.upower.enable     = true;

        # Clean unused blocks on SSDs weekly to keep write performance high
        services.fstrim.enable     = lib.mkDefault true;

        # power-profiles-daemon manages governors dynamically — do NOT set
        # cpuFreqGovernor at the same time (they conflict).
        services.power-profiles-daemon.enable = lib.mkDefault true;
        powerManagement.powertop.enable = true;

        # Set the active profile at boot according to the configured option
        systemd.services.set-power-profile = {
          description = "Set default system power profile";
          wantedBy = [ "multi-user.target" ];
          after = [ "power-profiles-daemon.service" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.power-profiles-daemon}/bin/powerprofilesctl set ${config.filosofo.hardware.powerProfile}";
            RemainAfterExit = true;
          };
        };
      }
    ];
  };
}
