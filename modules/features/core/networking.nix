{ self, inputs, ... }: {
  flake.nixosModules.networking = { pkgs, ... }: {
    networking.firewall.enable = true;
    networking.networkmanager.enable = true;
    environment.systemPackages = with pkgs; [
      openvpn
      curl
      wget
    ];
  };
}
