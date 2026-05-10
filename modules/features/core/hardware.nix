{ lib, pkgs, ... }: {
  flake.nixosModules.hardware-tuning = { config, pkgs, ... }: {
    options.filosofo.hardware = {
      gpu.type = lib.mkOption {
        type = lib.types.enum [ "none" "amd" "nvidia" "intel" ];
        default = "none";
        description = "Enable GPU specific drivers and tuning";
      };
      powerProfile = lib.mkOption {
        type = lib.types.enum [ "performance" "balanced" "powersave" ];
        default = "balanced";
        description = "System power profile";
      };
    };

    config = lib.mkMerge [
      (lib.mkIf (config.filosofo.hardware.gpu.type == "amd") {
        services.xserver.videoDrivers = [ "amdgpu" ];
        hardware.amdgpu.opencl.enable = true;
        hardware.graphics = {
          enable = true;
          enable32Bit = true;
        };
        environment.sessionVariables = {
          LIBVA_DRIVER_NAME = "radeonsi";
          VDPAU_DRIVER = "radeonsi";
        };
      })
      {
        # Generic desktop performance tuning
        services.thermald.enable = lib.mkDefault true;
        services.irqbalance.enable = lib.mkDefault true;
        powerManagement.cpuFreqGovernor = lib.mkDefault (
          if config.filosofo.hardware.powerProfile == "performance" then "performance"
          else if config.filosofo.hardware.powerProfile == "powersave" then "powersave"
          else "ondemand"
        );
      }
    ];
  };
}
