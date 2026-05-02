{ self, inputs, ... }: {
  flake.nixosModules.alacritty = { pkgs, userName, ... }: {
    home-manager.users.${userName} = { pkgs, ... }: {
      programs.alacritty = {
        enable = true;
        settings = {
          window.opacity = 0.9;
          font.size = 9;
        };
      };
    };
  };
}
