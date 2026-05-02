{ self, inputs, ... }: {
  flake.nixosModules.locale = { pkgs, timeZone, defaultLocale, extraLocale, keyMap, ... }: {
    time.timeZone = timeZone;
    i18n.defaultLocale = defaultLocale;
    i18n.extraLocaleSettings = {
      LC_ADDRESS = extraLocale;
      LC_IDENTIFICATION = extraLocale;
      LC_MEASUREMENT = extraLocale;
      LC_MONETARY = extraLocale;
      LC_NAME = extraLocale;
      LC_NUMERIC = extraLocale;
      LC_PAPER = extraLocale;
      LC_TELEPHONE = extraLocale;
      LC_TIME = extraLocale;
    };
    console.keyMap = keyMap;
    services.xserver.xkb = {
      layout = "latam";
      options = "";
    };
  };
}
