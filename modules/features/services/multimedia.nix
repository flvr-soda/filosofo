{ self, inputs, lib, ... }: {
  flake.nixosModules.multimedia = { config, userName, ... }: {
    options.filosofo.features.multimedia.enable = lib.mkEnableOption "Enable desktop multimedia tools (players, codecs)";

    config = lib.mkIf config.filosofo.features.multimedia.enable {
      # Desktop multimedia packages via home-manager
      home-manager.users.${userName} = { pkgs, ... }: {
        home.packages = with pkgs; [
          vlc
          imagemagick
          ffmpeg
          mediainfo
          jellyfin-desktop
          qbittorrent-enhanced
        ];
      };
    };
  };
}
