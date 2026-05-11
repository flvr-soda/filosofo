{ lib, userName, ... }:
{
  filosofo.features = {
    desktop.niri.enable = lib.mkDefault true;
    programming.enable = lib.mkDefault true;
    databases.enable = lib.mkDefault false;
    multimedia.enable = lib.mkDefault true;
    productivity.enable = lib.mkDefault true;
    kiwix.enable = lib.mkDefault false;
    llm.enable = lib.mkDefault false;
    nextcloud.enable = lib.mkDefault false;
    pihole.enable = lib.mkDefault false;
    tailscale.enable = lib.mkDefault true;
  };
}
