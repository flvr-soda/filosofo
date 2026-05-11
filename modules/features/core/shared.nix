# This is a flake-parts module that exports a shared NixOS module.
# It contains the base configuration for Home Manager and sops-nix that all hosts require.
{ self, inputs, userName, userFullName, userEmail, gitName, stateVersion, ... }: {
  flake.nixosModules.shared = { pkgs, ... }: {
    imports = [
      inputs.home-manager.nixosModules.home-manager
      inputs.sops-nix.nixosModules.default
    ];

    # Configure Home Manager to use global packages and pass specialArgs down
    # so that Home Manager submodules can access inputs, self, and userName.
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = { inherit inputs self userName userFullName userEmail gitName stateVersion; };
    home-manager.backupFileExtension = "backup";
  };
}
