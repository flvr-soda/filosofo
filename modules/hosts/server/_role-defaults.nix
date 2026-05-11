{ lib, ... }:
{
  filosofo.features = {
    arr-stack.enable = lib.mkDefault true;
    databases.enable = lib.mkDefault true;
    multimedia.enable = lib.mkDefault true;
    kiwix.enable = lib.mkDefault true;
    llm.enable = lib.mkDefault true;
    nextcloud.enable = lib.mkDefault true;
    pihole.enable = lib.mkDefault true;
    tailscale = {
      enable = lib.mkDefault true;
      useRoutingFeatures = lib.mkDefault "server";
      headlessJoin = lib.mkDefault true;
    };
    caddy.enable = lib.mkDefault true;
  };
}
