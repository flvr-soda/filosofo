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
    # Use the unstable channel of nixpkgs as the main package source.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager for managing user home environments declaratively.
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # This section defines what outputs this flake provides.
  outputs = { self, nixpkgs, home-manager, ... }@inputs: {

    # Define a NixOS system configuration named 'filosofo'
    nixosConfigurations.filosofo = inputs.nixpkgs.lib.nixosSystem {
      # The target system architecture: 64-bit Linux.
      system = "x86_64-linux";

      # Make all inputs available to module scope.
      specialArgs = { inherit inputs; };

      # List of modules to include in this system.
      modules = [
        # Main NixOS system configuration.
        ./NixOS/configuration.nix
        # Enables Home Manager as a NixOS module.
        home-manager.nixosModules.home-manager
        {
          home-manager.users.isma = import ./NixOS/home.nix;
        }
      ];
    };

  };
  
}
