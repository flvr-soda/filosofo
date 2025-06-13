# ================================================================ #
# =                           Filósofo                           = #
# ================================================================ #
{
  description = "Filósofo's flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    nixpkgs,
    home-manager,
    stylix,
    sops-nix,
    disko,
    ...
  }: let
    # User Variables
    hostname = "filosofo";
    username = "soda";
    gitUsername = "flvr-soda";
    gitEmail = "flavoredsoda@proton.me";
    theLocale = "en_US.UTF-8";
    theLCVariables = "es_VE.UTF-8";
    theTimezone = "America/Caracas";
  in {
    nixosConfigurations = {
      "${hostname}" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          inherit username;
          inherit hostname;
          inherit theTimezone;
          inherit theLocale;
          inherit theLCVariables;
        };
        modules = [
          ./configuration.nix
          sops-nix.nixosModules.sops
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          stylix.nixosModules.stylix
          {
            home-manager.extraSpecialArgs = {
              inherit username;
              inherit gitUsername;
              inherit gitEmail;
              inherit inputs;
              inherit hostname;
            };
            home-manager.backupFileExtension = "backup";
            home-manager.useUserPackages = true;
            home-manager.users."${username}" = import ./home.nix;
          }
        ];
      };
    };
  };
}
