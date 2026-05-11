{ self, inputs, ... }: {
  flake.nixosModules.networking = { pkgs, lib, ... }: {
    options.filosofo.networking.trustedLanCidr = lib.mkOption {
      type = lib.types.str;
      default = "192.168.1.0/24";
      description = "Trusted LAN CIDR for fail2ban ignoreip (SSH). Change if your home subnet differs.";
    };

    config = {
      networking.firewall.enable = true;
      networking.networkmanager.enable = true;
      environment.systemPackages = with pkgs; [
        openvpn
        curl
        wget
      ];
    };
  };
}
