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
    qbittorrent-enhanced
    vlc
    texstudio
    miktex
    imagemagick
    ffmpeg
  ];
}
