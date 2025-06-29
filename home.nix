{
  pkgs,
  inputs,
  username,
  gitUsername,
  gitEmail,
  ...
}: {
  # Paths and users home manager should manage
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";

  home.stateVersion = "25.05"; # Do not change this shit

  nixpkgs.config.allowUnfree = true;

  # STYLIX JUNK
  stylix.enable = true;
  stylix.polarity = "dark";
  stylix.targets.firefox.profileNames = ["${username}"];
  stylix.targets.qt.enable = true;
  stylix.targets.gtk.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-soft.yaml";

  qt.enable = true;
  gtk.enable = true;

  programs = {
    neovim = {
      enable = true;
    };

    firefox = {
      enable = true;
      profiles.${username} = {
        settings = {
          "dom.security.https_only_mode" = true;
          "browser.download.panel.shown" = true;
          "identity.fxaccounts.enabled" = false;
          "signon.rememberSignons" = false;
        };
        userChrome = ''
          /* some css */
        '';
        extensions.packages = with inputs.firefox-addons.packages."x86_64-linux"; [
          ublock-origin
          privacy-badger
        ];
      };
    };

    git = {
      enable = true;
      userName = "${gitUsername}";
      userEmail = "${gitEmail}";
      lfs.enable = true;
    };

    vscode = {
      enable = true;
      package = pkgs.vscode;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        yzhang.markdown-all-in-one
        jnoortheen.nix-ide
        eamodio.gitlens
        kamadorueda.alejandra
        ms-python.python
        ms-vscode.cpptools
        ms-azuretools.vscode-docker
        ms-vscode-remote.remote-ssh
      ];
      profiles.default.userSettings = {
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "security.workspace.trust.banner" = "never";
      };
    };
  };

  programs.home-manager.enable = true;
}
