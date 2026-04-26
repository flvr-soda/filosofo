{ pkgs, ... }:
let
  mods = import ../modules;
in {
  imports = [
    mods.system-base
    ./hardware-configuration.nix
  ];

  networking.hostName = "filosofo-server";

  # Keep server headless.
  services.xserver.enable = false;
  services.displayManager.sddm.enable = false;
  services.desktopManager.plasma6.enable = false;

  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "isma";
  };

  services.ollama = {
    enable = true;
    loadModels = [ "tinyllama" "deepseek-r1:1.5b" "qwen3.5" ];
  };
}
