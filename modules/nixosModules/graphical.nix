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

  environment.plasma6.excludePackages = with pkgs; [
    kdePackages.elisa
    kdePackages.khelpcenter
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
      profiles.${userName} = {
        isDefault = true;
        settings = {
          "dom.security.https_only_mode" = true;
          "browser.download.panel.shown" = true;
          "identity.fxaccounts.enabled" = false;
          "signon.rememberSignons" = false;
        };
        extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
          ublock-origin
          bitwarden
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
