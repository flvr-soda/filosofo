{ config, pkgs, inputs, ... }:

{
  # Paths and users home manager should manage
  home.username = "soda";
  home.homeDirectory = "/home/soda";

  home.stateVersion = "25.05"; # Do not change this shit
  
  nixpkgs.config.allowUnfree = true;

  programs = {

    firefox ={
      enable = true;
      profiles.soda = {
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
          # MUST
          bitwarden
          ublock-origin

          # MAYBE
          #tridactyl
        ];
      };
    };

    git = {
      enable = true;
      userName = "flvr-soda";
      userEmail = "flavoredsoda@proton.me";
      lfs.enable = true;
    };
    vscode = {
      enable = true;
      package = pkgs.vscode;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        yzhang.markdown-all-in-one
        jnoortheen.nix-ide
        ms-python.python
        ms-azuretools.vscode-docker
        ms-vscode-remote.remote-ssh
      ];
    };
  };

  # Install environment packages here
  home.packages = [

  ];

  # Manage dotfiles here
  home.file = {

  };

  # Manage environment variables here
  home.sessionVariables = {
 
  };

  programs.home-manager.enable = true;
}
