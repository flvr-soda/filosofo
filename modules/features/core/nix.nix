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
        auto-optimise-store = true;
      };
      optimise.automatic = true;
      optimise.dates = [ "03:45" ];
    };

    environment.systemPackages = with pkgs; [
      # LSPs & Formatters (flake formatter is nixfmt — see globals.nix)
      nil
      nixd
      nixfmt
      statix

      # Quality of Life
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


