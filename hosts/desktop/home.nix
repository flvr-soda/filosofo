{
  pkgs,
  ...
}:
let
  mods = import ../../modules/home;
in {
  imports = [
    mods.home-shared
    mods.development
    mods.gaming
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
