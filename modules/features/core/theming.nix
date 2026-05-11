{ ... }: {
  # Theming Module — Simplified to use static theme and basic fonts
  
  flake.nixosModules.theming = { config, pkgs, lib, ... }: {
    fonts = {
      packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        ubuntu-sans
        unifont
      ];

      fontconfig.defaultFonts = {
        serif = [ "Ubuntu Sans" ];
        sansSerif = [ "Ubuntu Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
      };
    };

    # System-wide theme is now provided via self.theme in other modules
  };
}
