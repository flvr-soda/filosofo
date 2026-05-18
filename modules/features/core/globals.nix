{
  self,
  lib,
  ...
}:
{
  systems = [ "x86_64-linux" ];

  perSystem =
    { system, pkgs, ... }:
    {
      formatter = pkgs.nixfmt;

      # Light CI: full module evaluation without building the system closure.
      checks = lib.mapAttrs' (
        name: cfg:
        lib.nameValuePair "nixos-${name}-eval" (
          pkgs.writeText "nixos-${name}-hostName.txt" cfg.config.networking.hostName
        )
      ) (
        lib.filterAttrs (_: cfg: cfg.pkgs.stdenv.hostPlatform.system == system) self.nixosConfigurations
      );
    };

  # Make common variables available to all other flake-parts modules.
  # This acts as our single source of truth for user details and state versions.
  _module.args = rec {
    userName = "isma";
    userFullName = "Isma";
    userEmail = "iearmada@proton.me";
    gitName = "flvr-soda";
    stateVersion = "25.05";
    timeZone = "America/Caracas";
    defaultLocale = "en_US.UTF-8";
    extraLocale = "es_VE.UTF-8";
    keyMap = "la-latin1";
    xkbLayout = "us,latam";
    xkbOptions = "grp:alt_shift_toggle";
    hostPrefix = "filosofo";
    servicesHost = "${hostPrefix}-desktop";
    sshKeyName = "id_github";
    mediaGroup = "media";
    mediaPath = "/storage/media";
  };
}
