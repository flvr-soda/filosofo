{ self, inputs, ... }: {
  flake.nixosModules.alacritty = { pkgs, lib, userName, ... }: {
    home-manager.users.${userName} = { pkgs, lib, ... }: {
      programs.alacritty = {
        enable = true;
        settings = {
          window.opacity = lib.mkDefault 0.9;
          font = {
            normal = {
              family = "JetBrainsMono Nerd Font";
              style = "Regular";
            };
            size = 10;
          };

          colors = {
            primary = {
              background = "0x${self.themeNoHash.base00}";
              foreground = "0x${self.themeNoHash.base06}";
            };
            cursor = {
              text = "0x${self.themeNoHash.base00}";
              cursor = "0x${self.themeNoHash.base06}";
            };
            normal = {
              black = "0x${self.themeNoHash.base00}";
              red = "0x${self.themeNoHash.base08}";
              green = "0x${self.themeNoHash.base0B}";
              yellow = "0x${self.themeNoHash.base0A}";
              blue = "0x${self.themeNoHash.base0D}";
              magenta = "0x${self.themeNoHash.base0E}";
              cyan = "0x${self.themeNoHash.base0C}";
              white = "0x${self.themeNoHash.base05}";
            };
            bright = {
              black = "0x${self.themeNoHash.base03}";
              red = "0x${self.themeNoHash.base08}";
              green = "0x${self.themeNoHash.base0B}";
              yellow = "0x${self.themeNoHash.base0A}";
              blue = "0x${self.themeNoHash.base0D}";
              magenta = "0x${self.themeNoHash.base0E}";
              cyan = "0x${self.themeNoHash.base0C}";
              white = "0x${self.themeNoHash.base07}";
            };
          };
        };
      };
    };

  };
}
