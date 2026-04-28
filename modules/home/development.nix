{ pkgs, ... }: {
  home.packages = with pkgs; [
    # General Programming
    gcc
    gnumake
    cmake
    pkg-config
    openjdk
    python3
    code-cursor
    # Database & Management Tools
    postgresql
    dbeaver-bin
    mariadb
    # Cybersecurity essentials 
    nmap
    whois
    proxychains
    wireshark
    aircrack-ng
    medusa
    sqlmap
  ];

  # Shared development ergonomics for dev machines.
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
