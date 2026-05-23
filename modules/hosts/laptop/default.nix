{ self, inputs, userName, userFullName, userEmail, gitName, stateVersion, timeZone, locale1, locale2, keyMap, xkbLayout, xkbOptions, hostPrefix, servicesHost, sshKeyName, mediaGroup, mediaPath, ... }: {
  flake.nixosConfigurations.laptop = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs self userName userFullName userEmail gitName stateVersion timeZone locale1 locale2 keyMap xkbLayout xkbOptions hostPrefix servicesHost sshKeyName mediaGroup mediaPath; };
    modules     = [ self.nixosModules.laptopConfiguration ];
  };
}
