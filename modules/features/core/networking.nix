{ self, inputs, ... }: {
  flake.nixosModules.networking = { config, pkgs, lib, ... }: {
    options.filosofo.networking.trustedLanCidr = lib.mkOption {
      type = lib.types.str;
      default = "192.168.1.0/24";
      description = "Trusted LAN CIDR for fail2ban ignoreip (SSH). Change if your home subnet differs.";
    };

    config = {
      networking.firewall.enable = true;
      networking.networkmanager.enable = true;
      environment.systemPackages = with pkgs; [
        curl
        wget
      ];

      services.openssh = {
        enable = true;
        startWhenNeeded = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
        extraConfig = ''
          AllowTcpForwarding yes
          X11Forwarding no
          AllowAgentForwarding no
          AuthenticationMethods publickey
        '';
      };

      programs.firejail.enable = true;


      services.resolved = {
        enable = true;
        settings = {
          Resolve = {
            DNSSEC = "opportunistic";
            DNSOverTLS = "opportunistic";
          };
        };
      };

      boot.kernel.sysctl = {
        "net.ipv4.conf.all.rp_filter" = 1;
        "net.ipv4.conf.default.rp_filter" = 1;
        "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
        "net.ipv4.conf.all.accept_source_route" = 0;
        "net.ipv4.conf.default.accept_source_route" = 0;
        "net.ipv4.conf.all.send_redirects" = 0;
        "net.ipv4.conf.default.send_redirects" = 0;
        "net.ipv4.conf.all.accept_redirects" = 0;
        "net.ipv4.conf.default.accept_redirects" = 0;
        "net.ipv4.tcp_syncookies" = 1;
        "net.ipv4.tcp_rfc1337" = 1;
      };
    };
  };
}
