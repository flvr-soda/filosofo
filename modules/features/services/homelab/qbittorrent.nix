{ lib, mediaGroup, ... }: {
  flake.nixosModules.qbittorrent = { config, pkgs, ... }:
    let
      cfg = config.filosofo.features.qbittorrent;
    in
    {
      options.filosofo.features.qbittorrent.enable =
        lib.mkEnableOption "Enable qBittorrent-nox BitTorrent client";

      config = lib.mkIf cfg.enable {
        users.users.qbittorrent-nox = {
          isSystemUser = true;
          group        = "qbittorrent-nox";
          extraGroups  = [ mediaGroup ];
          home         = "/var/lib/qbittorrent-nox";
          createHome   = true;
        };
        users.groups.qbittorrent-nox = { };

        systemd.services.qbittorrent-nox = {
          description = "qBittorrent-nox BitTorrent client";
          after       = [ "network.target" ];
          wantedBy    = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = "${pkgs.qbittorrent-enhanced-nox}/bin/qbittorrent-nox --webui-port=8282 --confirm-legal-notice";
            User           = "qbittorrent-nox";
            Group          = "qbittorrent-nox";
            StateDirectory = "qbittorrent-nox";
            Environment    = [
              "HOME=/var/lib/qbittorrent-nox"
              "QT_QPA_PLATFORM=offscreen"
            ];
            Restart = "on-failure";
          };
        };

        networking.firewall.allowedTCPPorts = [ 8282 6881 ];
        networking.firewall.allowedUDPPorts = [ 6881 ];
      };
    };
}
