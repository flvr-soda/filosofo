{ self, inputs, userName, userFullName, userEmail, gitName, stateVersion, timeZone, defaultLocale, extraLocale, keyMap, hostPrefix, ... }: {
  flake.nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs self userName userFullName userEmail gitName stateVersion timeZone defaultLocale extraLocale keyMap hostPrefix; };
    modules     = [ self.nixosModules.desktopConfiguration ];
  };
}
