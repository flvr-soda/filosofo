# Flake-parts module exporting the Jellyfin media server configuration.
# This module provides the Jellyfin server, necessary hardware acceleration packages,
# and opens the firewall for local network streaming.
{ self, inputs, ... }: {
  flake.nixosModules.jellyfin = {
    pkgs,
    userName,
    ...
  }: {
    # NixOS System-Level Configuration
    # --------------------------------
    
    # Add the necessary packages for Jellyfin and hardware transcoding
    environment.systemPackages = with pkgs; [
      jellyfin
      jellyfin-web
      jellyfin-ffmpeg
    ];

    # Enable and configure the Jellyfin service
    services.jellyfin = {
      enable = true;
      openFirewall = true;
      user = userName;
    };

    # Hardware Acceleration Tuning
    # Ensure the user running the service has permission to access the GPU for VA-API
    users.users.${userName}.extraGroups = [ "render" "video" ];
  };
}
