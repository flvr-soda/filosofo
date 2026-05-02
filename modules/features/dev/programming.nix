{ self, inputs, ... }: {
  flake.nixosModules.programming = { pkgs, userName, ... }: {
    # Home Manager User-Level Configuration
    home-manager.users.${userName} = { pkgs, ... }: {
      home.packages = with pkgs; [
        gcc
        gnumake
        cmake
        pkg-config
        openjdk
        python3
        nixfmt
        code-cursor
      ];

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    };
  };
}
