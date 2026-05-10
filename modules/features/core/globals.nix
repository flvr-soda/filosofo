{
  systems = [ "x86_64-linux" ];

  perSystem = { pkgs, ... }: {
    formatter = pkgs.nixfmt;
  };

  # Make common variables available to all other flake-parts modules.
  # This acts as our single source of truth for user details and state versions.
  _module.args = {
    userName = "isma";
    userFullName = "Isma";
    userEmail = "iearmada@proton.me";
    gitName = "flvr-soda";
    stateVersion = "25.05";
    timeZone = "America/Caracas";
    defaultLocale = "en_US.UTF-8";
    extraLocale = "es_VE.UTF-8";
    keyMap = "la-latin1";
    hostPrefix = "filosofo";
    mediaGroup = "media";
    mediaPath = "/storage/media";
  };
}
