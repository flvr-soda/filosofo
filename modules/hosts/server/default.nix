{ self, inputs, userName, userFullName, userEmail, gitName, stateVersion, ... }: {
  flake.nixosConfigurations.server = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs self userName userFullName userEmail gitName stateVersion; };
    modules = [
      ./hardware-configuration.nix
      self.nixosModules.base
      self.nixosModules.users
      self.nixosModules.secrets
      self.nixosModules.shared
      ({ pkgs, userName, ... }: {
        networking.hostName = "filosofo-server";

        services.xserver.enable = false;
        services.displayManager.sddm.enable = false;
        services.desktopManager.plasma6.enable = false;

        environment.systemPackages = with pkgs; [
          jellyfin
          jellyfin-web
          jellyfin-ffmpeg
        ];

        services.jellyfin = {
          enable = true;
          openFirewall = true;
          user = userName;
        };

        services.ollama = {
          enable = true;
          loadModels = ["tinyllama" "deepseek-r1:1.5b" "qwen3.5"];
        };
      })
    ];
  };
}
