{ self, inputs, ... }: {
  flake.nixosModules.nixConfig = { pkgs, inputs, ... }: {
    nixpkgs.config.allowUnfree = true;
    nix = {
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        allowed-users = [ "@wheel" ];
        auto-optimise-store = true;
      };
      optimise.automatic = true;
      optimise.dates = [ "03:45" ];
      gc.automatic = true;
      gc.dates = "weekly";
      gc.options = "--delete-older-than 7d";
    };
    nixpkgs.overlays = [
      inputs.antigravity-nix.overlays.default
    ];
  };
}
