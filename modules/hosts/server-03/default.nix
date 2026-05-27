{ self, inputs, userName, userFullName, userEmail, gitName, stateVersion, timeZone, locale1, locale2, keyMap, xkbLayout, xkbOptions, sshKeyName, mediaGroup, mediaPath, ... }: {
  flake.nixosConfigurations.server-03 = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs self userName userFullName userEmail gitName stateVersion timeZone locale1 locale2 keyMap xkbLayout xkbOptions sshKeyName mediaGroup mediaPath; };
    modules     = [ self.nixosModules.server03Configuration ];
  };
}
