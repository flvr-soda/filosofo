{ lib, ... }: {
  flake.nixosModules.media = { config, pkgs, userName, ... }:
    let
      cfg = config.filosofo.features.media;
    in
    {
      options.filosofo.features.media.enable =
        lib.mkEnableOption "Enable media tools";

      config = lib.mkIf cfg.enable {
        home-manager.users.${userName} = { pkgs, ... }: {
          home.packages = with pkgs; [
            pear-desktop
            blanket
            loupe
            file-roller
            evince
          ];

          programs.mpv = {
            enable = true;
            scripts = with pkgs.mpvScripts; [
              uosc
              mpris
            ];
            config = {
              hwdec = "auto-safe";
              vo = "gpu";
              profile = "gpu-hq";
              gpu-context = "wayland";
            };
          };
        };
      };
    };
}
