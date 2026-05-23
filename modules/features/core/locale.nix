{ self, inputs, ... }: {
  flake.nixosModules.locale = { pkgs, timeZone, locale1, locale2, keyMap, xkbLayout, xkbOptions, ... }: {
    time.timeZone = timeZone;
    
    i18n = {
      defaultLocale = locale1;

      supportedLocales = [
        "${locale1}/UTF-8"
        "${locale2}/UTF-8"
      ];

      extraLocaleSettings = {
        LC_ADDRESS = locale2;
        LC_IDENTIFICATION = locale2;
        LC_MEASUREMENT = locale2;
        LC_MONETARY = locale2;
        LC_NAME = locale2;
        LC_NUMERIC = locale2;
        LC_PAPER = locale2;
        LC_TELEPHONE = locale2;
        LC_TIME = locale2;
      };
    };

    console.keyMap = keyMap;
    services.xserver.xkb = {
      layout = xkbLayout;
      options = xkbOptions;
    };
  };
}
