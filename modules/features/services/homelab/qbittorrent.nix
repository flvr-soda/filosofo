{ lib, mediaGroup, pkgs, ... }: {
  flake.nixosModules.qbittorrent = { config, pkgs, ... }:
    let
      cfg     = config.filosofo.features.qbittorrent;
      warp    = config.filosofo.features.cloudflare-warp;
      cfgDir  = "/var/lib/qbittorrent-nox/.config/qBittorrent";
      cfgFile = "${cfgDir}/qBittorrent.conf";

      # Pre-start script that injects the interface binding into qBittorrent's
      # config file. Runs only when WARP is active.
      bindToWarpScript = pkgs.writeShellScript "qbittorrent-bind-warp" ''
        mkdir -p ${cfgDir}
        # Ensure the section header exists
        grep -q '^\[BitTorrent\]' ${cfgFile} 2>/dev/null || echo '[BitTorrent]' >> ${cfgFile}

        # Update or insert the interface name key
        if grep -q '^Session\\InterfaceName=' ${cfgFile} 2>/dev/null; then
          sed -i 's|^Session\\InterfaceName=.*|Session\\InterfaceName=${warp.interfaceName}|' ${cfgFile}
        else
          sed -i '/^\[BitTorrent\]/a Session\\InterfaceName=${warp.interfaceName}' ${cfgFile}
        fi
      '';
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
          after       = [ "network.target" ]
            ++ lib.optionals warp.enable [ "cloudflare-warp.service" ];
          wants       = lib.optionals warp.enable [ "cloudflare-warp.service" ];
          wantedBy    = [ "multi-user.target" ];
          serviceConfig = {
            ExecStartPre = lib.mkIf warp.enable "+${bindToWarpScript}";
            ExecStart    = "${pkgs.qbittorrent-enhanced-nox}/bin/qbittorrent-nox --webui-port=8282 --confirm-legal-notice";
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

