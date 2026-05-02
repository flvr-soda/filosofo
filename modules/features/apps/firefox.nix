{ self, inputs, ... }: {
  flake.nixosModules.firefox = { pkgs, userName, inputs, ... }: {
    home-manager.users.${userName} = { pkgs, inputs, ... }: {
      programs.firefox = {
        enable = true;
        configPath = ".mozilla/firefox";
        profiles.${userName} = {
          isDefault = true;
          settings = {
            "dom.security.https_only_mode" = true;
            "privacy.trackingprotection.enabled" = true;
            "privacy.trackingprotection.socialtracking.enabled" = true;
            "privacy.firstparty.isolate" = true;
            "network.cookie.cookieBehavior" = 1;
            "geo.enabled" = false;
            "dom.event.clipboardevents.enabled" = false;
            "media.peerconnection.enabled" = true;
            "toolkit.telemetry.enabled" = false;
            "browser.newtabpage.activity-stream.feeds.telemetry" = false;
            "browser.ping-centre.telemetry" = false;
            "datareporting.healthreport.uploadEnabled" = false;
            "browser.newtabpage.activity-stream.showSponsored" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "identity.fxaccounts.enabled" = false;
            "signon.rememberSignons" = true;
            "browser.download.panel.shown" = true;
          };
          extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
            ublock-origin
            bitwarden
          ];
          bookmarks = {
            force = true;
            settings = [
              {
                name = "Toolbar";
                toolbar = true;
                bookmarks = [
                  { name = "FMHY"; url = "https://fmhy.net"; }
                  { name = "GitHub"; url = "https://github.com"; }
                  { name = "YouTube"; url = "https://youtube.com"; }
                  { name = "Gemini"; url = "https://gemini.google.com"; }
                ];
              }
            ];
          };
          search = {
            force = true;
            default = "ddg";
          };
        };
      };
    };
  };
}
