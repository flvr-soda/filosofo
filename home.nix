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
  stylix.targets.gnome.enable = true;
  stylix.targets.qt.enable = true;
  stylix.targets.gtk.enable = true;
  stylix.base16Scheme = {
    base00 = "282828";
    base01 = "3c3836";
    base02 = "504945";
    base03 = "665c54";
    base04 = "bdae93";
    base05 = "d5c4a1";
    base06 = "ebdbb2";
    base07 = "fbf1c7";
    base08 = "fb4934";
    base09 = "fe8019";
    base0A = "fabd2f";
    base0B = "b8bb26";
    base0C = "8ec07c";
    base0D = "83a598";
    base0E = "d3869b";
    base0F = "d65d0e";
  };

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
          tridactyl
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

    gh.enable = true;

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
