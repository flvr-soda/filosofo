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

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
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

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };


  outputs = inputs:
    let
      userName = "isma";
      userFullName = "Isma";
      userEmail = "iearmada@proton.me";
      gitName = "flvr-soda";
      stateVersion = "25.05";
      timeZone = "America/Caracas";
      locale1 = "en_US.UTF-8";
      locale2 = "es_VE.UTF-8";
      keyMap = "la-latin1";
      xkbLayout = "us,latam";
      xkbOptions = "grp:alt_shift_toggle";
      sshKeyName = "id_github";
      mediaGroup = "media";
      mediaPath = "/storage/media";

      globalArgs = {
        inherit userName userFullName userEmail gitName stateVersion
                timeZone locale1 locale2 keyMap xkbLayout xkbOptions
                sshKeyName mediaGroup mediaPath;
      };
    in
    inputs.flake-parts.lib.mkFlake
      {
        inherit inputs;
        specialArgs = globalArgs;
      }
      ({ self, lib, ... }@args: {
        imports = [
          (inputs.import-tree ./modules)
        ];

        systems = [ "x86_64-linux" ];

        perSystem =
          { system, pkgs, ... }:
          {
            formatter = pkgs.nixfmt;
          };


        flake.colmena = {
          meta = {
            nixpkgs      = import inputs.nixpkgs { system = "x86_64-linux"; };
            specialArgs  = {
              inherit inputs self userName userFullName userEmail gitName
                      stateVersion timeZone locale1 locale2 keyMap
                      xkbLayout xkbOptions sshKeyName mediaGroup mediaPath;
            };
          };

          desktop-main = {
            deployment = {
              targetHost           = "localhost";
              targetUser           = "root";
              allowLocalDeployment = true;
            };
            imports = [ self.nixosModules.desktopMainConfiguration ];
          };

          laptop-dev = {
            deployment = {
              targetHost           = "localhost";
              targetUser           = "root";
              allowLocalDeployment = true;
            };
            imports = [ self.nixosModules.laptopDevConfiguration ];
          };
          
          laptop-basic = {
            deployment = {
              targetHost           = "localhost";
              targetUser           = "root";
              allowLocalDeployment = true;
            };
            imports = [ self.nixosModules.laptopBasicConfiguration ];
          };

          server-01 = {
            deployment = {
              targetHost = "server-01.local";
              targetUser = "root";
            };
            imports = [ self.nixosModules.server01Configuration ];
          };
          
          server-02 = {
            deployment = {
              targetHost = "server-02.local";
              targetUser = "root";
            };
            imports = [ self.nixosModules.server02Configuration ];
          };
          
          server-03 = {
            deployment = {
              targetHost = "server-03.local";
              targetUser = "root";
            };
            imports = [ self.nixosModules.server03Configuration ];
          };
        };
      });
}