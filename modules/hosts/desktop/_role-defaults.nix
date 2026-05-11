{ lib, userName, ... }:
{
  filosofo.features = {
    desktop.niri.enable = lib.mkDefault true;
    programming.enable = lib.mkDefault true;
    programming.enableHardwareDev = lib.mkDefault true;
    databases.enable = lib.mkDefault true;
    arr-stack.enable = lib.mkDefault true;
    jellyfin.enable = lib.mkDefault true;
    navidrome.enable = lib.mkDefault true;
    kavita.enable = lib.mkDefault true;
    multimedia.enable = lib.mkDefault true;
    productivity.enable = lib.mkDefault true;
    kiwix.enable = lib.mkDefault false;
    llm.enable = lib.mkDefault false;
    nextcloud.enable = lib.mkDefault true;
    pihole.enable = lib.mkDefault false;
    tailscale.enable = lib.mkDefault true;
    caddy.enable = lib.mkDefault true;
  };

  home-manager.users.${userName} = { pkgs, ... }: {
    home.packages = with pkgs; [ ];

    xdg.userDirs = {
      enable = true;
      createDirectories = false;
      documents = "/home/${userName}/storage/documents";
      download = "/home/${userName}/storage/downloads";
      pictures = "/home/${userName}/storage/pictures";
      music = "/home/${userName}/storage/music";
      videos = "/home/${userName}/storage/videos";
      templates = "/home/${userName}/storage/templates";
      desktop = "/home/${userName}/Desktop";
      publicShare = "/home/${userName}/Public";
      setSessionVariables = true;
    };
  };
}
