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
    # Desktop-focused media/productivity stack.
    qbittorrent-enhanced
    vlc
    texstudio
    libreoffice
    miktex
    kiwix
    imagemagick
    ffmpeg
    wine
    protonup-ng
    winetricks
    google-antigravity
    cava
    cmatrix
  ];
}
