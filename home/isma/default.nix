{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./programs/default.nix
    ./services/default.nix
    ./themes/default.nix
  ];

  nixpkgs.overlays = [
    inputs.antigravity-nix.overlays.default
    inputs.nur.overlays.default
  ];
  nixpkgs.config.allowUnfree = true;

  home = {
    username = "isma";
    homeDirectory = "/home/isma";
    stateVersion = "25.05";

    packages = with pkgs; [
      qbittorrent-enhanced
      vlc
      texstudio
      libreoffice
      miktex
      kew
      kiwix
      imagemagick
      nixd
      google-antigravity
      fastfetch
      tree
      cava
      cmatrix
      btop
      yazi
      eza
      bat
      ripgrep
      ffmpeg
      proxychains
      medusa
      nmap
      whois
      sqlmap
      wireshark
      aircrack-ng
      p7zip
      unrar
      wine
      protonup-ng
      winetricks
    ];
  };

  programs.home-manager.enable = true;
}
