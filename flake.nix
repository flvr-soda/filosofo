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

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
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
    # Define common special args
    commonSpecialArgs = {inherit inputs username gitUsername gitEmail hostname theTimezone theLocale theLCVariables;};
    # Hosts definition
    hosts = {
      "filosofo-laptop" = {
        isDesktop = true; # Used to enable/disable desktop-specific configs (like Hyprland)
        isServer = false;
        device = "/dev/sda";
      };
      "filosofo-desktop" = {
        isDesktop = true;
        isServer = false;
        device = "/dev/nvme0n1";
      };
      "filosofo-server" = {
        isDesktop = false;
        isServer = true;
        device = "/dev/sda"; # adjust
      };
    };
  in {
    nixosConfigurations = nixpkgs.lib.mapAttrs (hostname: hostAttrs:
      nixpkgs.lib.nixosSystem {
        specialArgs = commonSpecialArgs // hostAttrs;
        modules = [
          ./hosts/${hostname}/configuration.nix
          sops-nix.nixosModules.sops
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          stylix.nixosModules.stylix
          {
            home-manager.extraSpecialArgs = commonSpecialArgs // hostAttrs;
            home-manager.backupFileExtension = "backup";
            home-manager.useUserPackages = true;
            home-manager.users."${username}" = import ./hosts/${hostname}/home.nix;
          }
        ];
      })
    hosts;

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

          # General Utilities
          git
          tmux
          neovim
          jq
          fzf
        ];

        # shellHook runs commands when you enter the dev shell
        shellHook = ''
          echo "I rot, but beautifully"
        '';
      };
    # --- End of Cybersecurity Dev Shell ---
  };
}
