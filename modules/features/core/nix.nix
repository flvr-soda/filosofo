{ self, inputs, ... }: {
  flake.nixosModules.nixConfig = { pkgs, inputs, userName, ... }: {
    imports = [
      inputs.nix-index-database.nixosModules.nix-index
    ];

    programs.nix-index-database.comma.enable = true;

    programs.direnv = {
      enable = true;
      silent = false;
      nix-direnv.enable = true;
    };

    programs.nix-ld.enable = true;


    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/home/${userName}/filosofo";
    };

    nixpkgs.config.allowUnfree = true;
    nix = {
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        allowed-users = [ "@wheel" ];
        trusted-users = [ "root" "@wheel" ];
        auto-optimise-store = true;

        # Centralized Binary Caches
        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://nix-gaming.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        ];
      };
      optimise.automatic = true;
      optimise.dates = [ "03:45" ];
    };

    environment.systemPackages = with pkgs; [
      # Flake formatter is nixfmt (configured globally)
      nil
      nixd
      nixfmt
      statix


      manix
      nix-tree
      nix-diff
      nvd
    ];

    nixpkgs.overlays = [
      inputs.antigravity-nix.overlays.default
      (final: prev: {
        # OpenLDAP: disable tests; test017-syncreplication-refresh flakes on some builders.
        # Revisit when bumping nixpkgs if upstream fixes the test.
        openldap = prev.openldap.overrideAttrs (oldAttrs: {
          doCheck = false;
        });
      })
    ];

  };
}


