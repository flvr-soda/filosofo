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

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
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
          #inputs.disko.nixosModules.default
          #(import ./disko.nix {device = "/dev/sda";})
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
    # --- Cybersecurity Dev Shell ---
    # This defines a development environment that you can enter using 'nix develop'
    devShells.x86_64-linux.default = let
      pkgs = import nixpkgs {system = "x86_64-linux";};
    in
      pkgs.mkShell {
        buildInputs = with pkgs; [
          # Network Scanning & Reconnaissance
          nmap
          whois
          theharvester
          sqlmap
          dnsenum
          gobuster
          nikto

          # Wireless Hacking
          aircrack-ng
          kismet
          bettercap

          # Proxy & Anonymity
          proxychains
          tor
          torsocks

          # Password Cracking & Hashing
          john
          medusa
          hashcat
          hashcat-utils

          # Exploitation & Vulnerability Analysis
          metasploit-framework
          burpsuite
          ghidra-bin
          ncrack

          # Packet Analysis & Forensics
          wireshark-cli
          wireshark

          # General Utilities (helpful in any dev shell)
          git
          tmux
          neovim
          jq
          fzf
        ];

        # shellHook runs commands when you enter the dev shell
        shellHook = ''
          echo "HACK SOME CRAP!"
        '';
      };
    # --- End of Cybersecurity Dev Shell ---
  };
}
