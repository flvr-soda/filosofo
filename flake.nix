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

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    preservation = {
      url = "github:nix-community/preservation";
    };

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    import-tree.url = "github:vic/import-tree";

    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming.url = "github:fufexan/nix-gaming";
  };


  outputs = inputs: inputs.flake-parts.lib.mkFlake
    { inherit inputs; }
    ({ self, lib, userName, userFullName, userEmail, gitName, stateVersion, timeZone, defaultLocale, extraLocale, keyMap, xkbLayout, xkbOptions, hostPrefix, servicesHost, sshKeyName, mediaGroup, mediaPath, ... }: {
      imports = [
        (inputs.import-tree ./modules)
      ];

      flake.colmena = {
        meta = {
          nixpkgs      = import inputs.nixpkgs { system = "x86_64-linux"; };
          specialArgs  = {
            inherit inputs self userName userFullName userEmail gitName
                    stateVersion timeZone defaultLocale extraLocale keyMap
                    xkbLayout xkbOptions hostPrefix servicesHost sshKeyName mediaGroup mediaPath;
          };
        };

        desktop = {
          deployment = {
            targetHost           = "localhost";
            targetUser           = "root";
            allowLocalDeployment = true;
          };
          imports = [ self.nixosModules.desktopConfiguration ];
        };

        server = {
          deployment = {
            targetHost = "${hostPrefix}-server";
            targetUser = "root";
          };
          imports = [ self.nixosModules.serverConfiguration ];
        };

        laptop = {
          deployment = {
            targetHost           = "${hostPrefix}-laptop";
            targetUser           = "root";
            allowLocalDeployment = true;
          };
          imports = [ self.nixosModules.laptopConfiguration ];
        };
      };
    });
}
