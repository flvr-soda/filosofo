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
    kew
    tree
    cava
    cmatrix
  ];
}
