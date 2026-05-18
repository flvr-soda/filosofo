{ self, inputs, lib, ... }: {
  flake.nixosModules.browsers = { config, pkgs, userName, servicesHost, ... }:
    let
      cfg = config.filosofo.features.browsers;
    in
    {
      options.filosofo.features.browsers.enable =
        lib.mkEnableOption "Enable web browsers";

      config = lib.mkIf cfg.enable {
        home-manager.users.${userName} = { pkgs, lib, ... }: {
          home.packages = with pkgs; [
            tor-browser
          ];

          programs.firefox = {
            enable     = true;
            configPath = ".mozilla/firefox";
            profiles.${userName} = {
              isDefault = true;
              settings = {
                "dom.security.https_only_mode"                       = true;
                "privacy.trackingprotection.enabled"                 = true;
                "privacy.trackingprotection.socialtracking.enabled"  = true;
                "privacy.firstparty.isolate"                         = true;
                "network.cookie.cookieBehavior"                      = 1;
                "geo.enabled"                                        = false;
                "dom.event.clipboardevents.enabled"                  = false;
                "media.peerconnection.enabled"                       = true;
                "toolkit.telemetry.enabled"                          = false;
                "browser.newtabpage.activity-stream.feeds.telemetry" = false;
                "browser.ping-centre.telemetry"                      = false;
                "datareporting.healthreport.uploadEnabled"           = false;
                "browser.newtabpage.activity-stream.showSponsored"   = false;
                "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
                "identity.fxaccounts.enabled"                        = false;
                "signon.rememberSignons"                             = true;
                "browser.download.panel.shown"                       = true;
              };
              extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
                ublock-origin
                bitwarden
              ];
              bookmarks = {
                force = true;
                settings = [{
                  name    = "Toolbar";
                  toolbar = true;
                  bookmarks = [
                    {
                      name = "Daily";
                      bookmarks = [
                        { name = "Whatsapp";    url = "https://web.whatsapp.com"; }
                        { name = "Gmail";       url = "https://mail.google.com"; }
                        { name = "Proton Mail"; url = "https://mail.proton.me"; }
                        { name = "YouTube";     url = "https://youtube.com"; }
                        { name = "Gemini";      url = "https://gemini.google.com"; }
                        { name = "Sci-Hub";     url = "https://sci-hub.st"; }
                      ];
                    }
                    {
                      name = "Dev & Tools";
                      bookmarks = [
                        { name = "GitHub";      url = "https://github.com"; }
                        { name = "Overleaf";    url = "https://www.overleaf.com"; }
                        { name = "Distro sea";  url = "https://distrosea.com"; }
                        { name = "FMHY";        url = "https://fmhy.net"; }
                        { name = "Tailscale";   url = "https://login.tailscale.com/admin/machines"; }
                      ];
                    }
                    {
                      name = "Homelab";
                      bookmarks = [
                        { name = "Nextcloud";   url = "http://${servicesHost}:80"; }
                        { name = "qBittorrent"; url = "http://${servicesHost}:8282"; }
                      ];
                    }
                    {
                      name = "Media & Arr";
                      bookmarks = [
                        { name = "Jellyfin";    url = "http://${servicesHost}:8096"; }
                        { name = "Seerr";       url = "http://${servicesHost}:5055"; }
                        { name = "Prowlarr";    url = "http://${servicesHost}:9696"; }
                        { name = "Sonarr";      url = "http://${servicesHost}:8989"; }
                        { name = "Radarr";      url = "http://${servicesHost}:7878"; }
                        { name = "Lidarr";      url = "http://${servicesHost}:8686"; }
                        { name = "Readarr";     url = "http://${servicesHost}:8787"; }
                        { name = "Bazarr";      url = "http://${servicesHost}:6767"; }
                      ];
                    }
                    {
                      name = "Library & Audio";
                      bookmarks = [
                        { name = "Navidrome";   url = "http://${servicesHost}:4533"; }
                        { name = "Kavita";      url = "http://${servicesHost}:5000"; }
                        { name = "Kiwix";       url = "http://${servicesHost}:8081"; }
                      ];
                    }
                    {
                      name = "AI Services";
                      bookmarks = [
                        { name = "Open-WebUI";  url = "http://${servicesHost}:8080"; }
                        { name = "SearXNG";     url = "http://${servicesHost}:8888"; }
                      ];
                    }
                  ];
                }];
              };
              search = {
                force   = true;
                default = "ddg";
              };
            };
          };
        };
      };
    };
}
