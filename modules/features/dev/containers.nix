{ self, inputs, ... }: {
  flake.nixosModules.containers = { pkgs, userName, ... }: {
    # NixOS System-Level Configuration
    virtualisation.docker = {
      enable = true;
      autoPrune.enable = true;
    };

    users.users.${userName}.extraGroups = [ "docker" ];

    # Home Manager User-Level Configuration
    home-manager.users.${userName} = { pkgs, ... }: {
      home.packages = with pkgs; [
        docker-compose
      ];
    };
  };
}
