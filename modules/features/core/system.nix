{ self, inputs, ... }: {
  flake.nixosModules.system = { pkgs, userName, stateVersion, gitName, userEmail, ... }: {
    documentation.enable = false;
    documentation.nixos.enable = false;

    environment.systemPackages = with pkgs; [
      coreutils
      util-linux
      pciutils
      home-manager
      sops
      age
    ];

    services.printing.enable = true;
    services.printing.drivers = [ pkgs.splix pkgs.samsung-unified-linux-driver ];
    services.ipp-usb.enable = true;
    hardware.printers.ensurePrinters = [
      {
        name = "ML-1660";
        deviceUri = "usb://Samsung/ML-1660%20Series?serial=Z508BKBZ701777X";
        model = "samsung/ml1660.ppd";              
      }
    ];

    system.stateVersion = stateVersion;

    # Home Manager
    home-manager.users.${userName} = { pkgs, ... }: {
      home.stateVersion = stateVersion;
      home.packages = with pkgs; [
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
