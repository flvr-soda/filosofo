{ self, inputs, ... }: {
  flake.nixosModules.system = { pkgs, userName, stateVersion, gitName, userEmail, ... }: {
    documentation.enable = false;
    documentation.nixos.enable = false;

    environment.systemPackages = with pkgs; [
      coreutils
      util-linux
      pciutils
      home-manager
      inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    system.stateVersion = stateVersion;

    # Home Manager
    home-manager.users.${userName} = { pkgs, ... }: {
      home.stateVersion = stateVersion;
      home.packages = with pkgs; [
        nixd
        p7zip
        unrar
      ];

      programs.home-manager.enable = true;
      programs.git = {
        enable = true;
        lfs.enable = true;
        settings = {
          user = {
            name = gitName;
            email = userEmail;
          };
          init.defaultBranch = "main";
          url."git@github.com:".insteadOf = "https://github.com/";
        };
      };
    };
  };
}
