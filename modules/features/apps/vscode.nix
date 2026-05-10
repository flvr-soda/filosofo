{ self, inputs, ... }: {
  flake.nixosModules.vscode = { pkgs, userName, ... }: {
    home-manager.users.${userName} = { pkgs, ... }: {
      programs.vscodium = {
        enable = true;
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
