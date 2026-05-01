# Flake-parts module exporting the graphical desktop environment configuration.
# This provides Plasma 6, SDDM, and common graphical user applications (Firefox, VSCode).
{ self, inputs, ... }: {
  flake.nixosModules.graphical = {
    pkgs,
    userName,
    inputs,
    ...
  }: {
  # NixOS System-Level Configuration
  # --------------------------------
  
  # Enable the X11 windowing system and SDDM display manager with Wayland support
  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;
  services.displayManager.autoLogin = {
    enable = true;
    user = userName;
  };

  networking.networkmanager.enable = true;

  # Exclude xterm since Konsole is used
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.excludePackages = [ pkgs.xterm ];

  environment.plasma6.excludePackages = with pkgs; [
    # Replaced by VLC
    kdePackages.elisa
    # Replaced by Kiwix/Firefox
    kdePackages.khelpcenter
    # Replaced by VSCodium / nixd
    kdePackages.kate
    # Removed because it conflicts with auto-login
    kdePackages.kwalletmanager
    kdePackages.kwallet-pam
  ];

  # Home Manager User-Level Configuration
  # -------------------------------------
  home-manager.users.${userName} = {
    pkgs,
    inputs,
    ...
  }: {
    home.packages = with pkgs; [
      google-antigravity
      kiwix
      libreoffice
    ];

    # Configure Firefox with hardened settings and extensions from NUR
    programs.firefox = {
      enable = true;
      
      # Silence warning for Home Manager < 26.05
      configPath = ".mozilla/firefox";
      
      profiles.${userName} = {
        isDefault = true;
        settings = {
          # Privacy & Tracking Protection
          "dom.security.https_only_mode" = true;
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          "privacy.firstparty.isolate" = true;
          "network.cookie.cookieBehavior" = 1;

          # Anti-Fingerprinting & Leaks
          "geo.enabled" = false;
          "dom.event.clipboardevents.enabled" = false;
          "media.peerconnection.enabled" = true; # Kept enabled as per user request

          # Telemetry & Data Collection
          "toolkit.telemetry.enabled" = false;
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.ping-centre.telemetry" = false;
          "datareporting.healthreport.uploadEnabled" = false;

          # UI Cleanliness
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

          # Credentials
          "identity.fxaccounts.enabled" = false;
          "signon.rememberSignons" = false;
          "browser.download.panel.shown" = true;
        };
        extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
          ublock-origin
          bitwarden
          adnauseam
        ];
        search = {
          force = true;
          default = "ddg";
        };
      };
    };

    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      profiles.default.userSettings = {
        "nix.enableLanguageServer" = true;
        "git.autofetch" = true;
        "nix.serverPath" = "nixd";
        "security.workspace.trust.banner" = "never";
        "files.autoSave" = "afterDelay";
        "editor.minimap.autohide" = "mouseover";
      };
    };
  };
};
}
