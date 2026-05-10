# Centralized Gruvbox Material Dark theme — single source of truth for all UI modules.
# Following vimjoyer/nixconf's theme.nix pattern: export base16 colors as flake-level attrs
# so they can be referenced as `self.theme.base0B` from any module.
let
  theme = {
    base00 = "#282828"; # bg
    base01 = "#3c3836"; # dark bg
    base02 = "#504945"; # selection
    base03 = "#665c54"; # comments
    base04 = "#bdae93"; # dark fg
    base05 = "#d5c4a1"; # fg
    base06 = "#ebdbb2"; # light fg
    base07 = "#fbf1c7"; # lightest fg
    base08 = "#fb4934"; # red
    base09 = "#fe8019"; # orange
    base0A = "#fabd2f"; # yellow
    base0B = "#b8bb26"; # green
    base0C = "#8ec07c"; # cyan
    base0D = "#83a598"; # blue
    base0E = "#d3869b"; # magenta
    base0F = "#f28534"; # brown/orange
  };

  stripHash = str:
    if builtins.substring 0 1 str == "#"
    then builtins.substring 1 (builtins.stringLength str - 1) str
    else str;

  themeNoHash = builtins.mapAttrs (_: v: stripHash v) theme;
in {
  flake = {
    inherit theme themeNoHash;
  };
}
