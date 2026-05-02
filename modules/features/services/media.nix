{ self, inputs, ... }: {
  flake.nixosModules.media = { pkgs, ... }: {
    # Music Streaming
    services.navidrome = {
      enable = true;
      openFirewall = true;
      settings = {
        MusicFolder = "/var/lib/navidrome/music";
      };
    };

    # Books and Audiobooks
    services.audiobookshelf = {
      enable = true;
      openFirewall = true;
      port = 8000;
    };

    # Ensure directories exist
    systemd.tmpfiles.rules = [
      "d /var/lib/navidrome/music 0755 navidrome navidrome - -"
      "d /var/lib/audiobookshelf 0755 audiobookshelf audiobookshelf - -"
    ];
  };
}
