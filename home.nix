{ pkgs, inputs, ... }:

{ 
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence

  ];

  home.stateVersion = "23.11"; # Please read the comment before changing.

  programs = {
    git = {
      enable = true;
      userName = "iearmada";
      userEmail = "flavoredsoda@proton.me";
    };
    vscode = {
      enable = true;
      package = pkgs.vscodium;
      extensions = with pkgs.vscode-extensions; [
        vscodevim.vim
        yzhang.markdown-all-in-one
        jnoortheen.nix-ide
        ms-python.python
#        gitkraken.gitlens 
      ];
    };
  };

  home = {
    persistence."/home/soda" = {
      directories = [
        "Downloads"
        "Music"
        "Pictures"
        "Documents"
        "Videos"
        "VirtualBox VMs"
        ".gnupg"
        ".ssh"
        ".nixops"
        ".local/share/keyrings"
        ".local/share/direnv"
        {
        directory = ".local/share/Steam";
        method = "symlink";
        }
      ];
      files = [
        ".screenrc"
      ];
      allowOther = true;
    };
  };
}
