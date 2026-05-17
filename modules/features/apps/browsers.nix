{ self, inputs, lib, ... }: {
  flake.nixosModules.browsers = { config, pkgs, userName, ... }:
    let
      cfg = config.filosofo.features.browsers;
    in
    {
      options.filosofo.features.browsers.enable =
        lib.mkEnableOption "Enable web browsers (Firefox, Tor)";

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
                    { name = "FMHY";        url = "https://fmhy.net"; }
                    { name = "Whatsapp";    url = "https://web.whatsapp.com"; }
                    { name = "GitHub";      url = "https://github.com"; }
                    { name = "Gmail";       url = "https://mail.google.com"; }
                    { name = "Proton Mail"; url = "https://mail.proton.me"; }
                    { name = "YouTube";     url = "https://youtube.com"; }
                    { name = "Gemini";      url = "https://gemini.google.com"; }
                    { name = "Tailscale";   url = "https://login.tailscale.com/admin/machines"; }
                    { name = "Distro sea";  url = "https://distrosea.com"; }
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
