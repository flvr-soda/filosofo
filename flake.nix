/*
 ___  _  _    //          __
| __|(_)| | ___  ___ ___  / _| ___
| _| | || |/ _ \(_-// _ \|  _|/ _ \
|_|  |_||_|\___//__/\___/|_|  \___/
*/
{
  description = "A Filósofo's NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, agenix, firefox-addons, antigravity-nix, ... }@inputs:
  let
    userName = "isma";
  in {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs userName; };
        modules = [
          ./hosts/desktop
          home-manager.nixosModules.home-manager
          agenix.nixosModules.default
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${userName} = import ./hosts/desktop/home.nix;
            home-manager.extraSpecialArgs = { inherit inputs userName; };
            home-manager.backupFileExtension = "backup";
          }
        ];
      };

      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs userName; };
        modules = [
          ./hosts/laptop
          home-manager.nixosModules.home-manager
          agenix.nixosModules.default
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${userName} = import ./hosts/laptop/home.nix;
            home-manager.extraSpecialArgs = { inherit inputs userName; };
            home-manager.backupFileExtension = "backup";
          }
        ];
      };

      server = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs userName; };
        modules = [
          ./hosts/server
          agenix.nixosModules.default
        ];
      };
    };
  };
}
