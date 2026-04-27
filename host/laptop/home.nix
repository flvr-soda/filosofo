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
    kew
    tree
    cava
    cmatrix
  ];
}
