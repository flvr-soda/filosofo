{
  pkgs,
  ...
}:
let
  mods = import ../modules;
in {
  imports = [
    mods.home-shared
  ];

  home.packages = with pkgs; [
    # Laptop is the primary cybersecurity workstation.
    kew
    nmap
    whois
    proxychains
    wireshark
    aircrack-ng
    medusa
    sqlmap
    # Keep gaming utility parity.
    wine
    protonup-ng
    winetricks
  ];
}
