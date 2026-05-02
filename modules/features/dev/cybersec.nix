{ self, inputs, ... }: {
  flake.nixosModules.cybersec = { pkgs, userName, ... }: {
    # Home Manager User-Level Configuration
    home-manager.users.${userName} = { pkgs, ... }: {
      home.packages = with pkgs; [
        nmap
        whois
        proxychains
        aircrack-ng
        medusa
        sqlmap
      ];
    };
  };
}
