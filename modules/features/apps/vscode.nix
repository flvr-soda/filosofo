{ self, inputs, ... }: {
  flake.nixosModules.vscode = { pkgs, userName, ... }: {
    home-manager.users.${userName} = { pkgs, ... }: {
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
