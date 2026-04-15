/*
 ___  _  _    //          __
| __|(_)| | ___  ___ ___  / _| ___
| _| | || |/ _ \(_-// _ \|  _|/ _ \
|_|  |_||_|\___//__/\___/|_|  \___/
*/
{
  description = "A Filósofo's NixOS flake";

  # Input sources for this flake
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # This section defines what outputs this flake provides.
  outputs = { self, nixpkgs, home-manager, nur, antigravity-nix, ... }@inputs: {

    # Define a NixOS system configuration named 'desktop'
    nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
      # The target system architecture: 64-bit Linux.
      system = "x86_64-linux";

      # Make all inputs available to module scope.
      specialArgs = { inherit inputs; };

      # List of modules to include in this system.
      modules = [
        ./Hosts/configuration.nix
        ./Hosts/desktop/hardware-configuration.nix
        ./Hosts/desktop/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.users.isma = import ./Hosts/home.nix;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.backupFileExtension = "backup";
        }
      ];
    };

    # Define a NixOS system configuration named 'laptop'
    nixosConfigurations.laptop = inputs.nixpkgs.lib.nixosSystem {
      # The target system architecture: 64-bit Linux.
      system = "x86_64-linux";

      # Make all inputs available to module scope.
      specialArgs = { inherit inputs; };

      # List of modules to include in this system.
      modules = [
        ./Hosts/configuration.nix
        ./Hosts/laptop/hardware-configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.users.isma = import ./Hosts/home.nix;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.backupFileExtension = "backup";
        }
      ];
    };
  };
}
