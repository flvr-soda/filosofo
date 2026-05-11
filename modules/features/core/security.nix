{ self, inputs, ... }: {
  flake.nixosModules.security = { pkgs, lib, config, ... }: {
    security = {
      polkit.enable = true;
      rtkit.enable = true;
      sudo = {
        execWheelOnly = true;
        extraConfig = "Defaults insults";
      };

      # Memory protection and kernel hardening
      protectKernelImage = true;
      lockKernelModules = false; # Set to true for maximum security, but can break some hardware/drivers

      apparmor = {
        enable = true;
        killUnconfinedConfinables = true;
        packages = with pkgs; [ apparmor-utils apparmor-profiles ];
      };
    };

    # Enable Firejail sandboxing
    programs.firejail.enable = true;

    # Brute force protection
    services.fail2ban = {
      enable = true;
      maxretry = 5;
      ignoreIP = [
        "127.0.0.1/8"
        config.filosofo.networking.trustedLanCidr
      ];
    };

    # Kernel sysctl hardening
    boot.kernel.sysctl = {
      # TCP/IP stack hardening
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
      
      # Buffer overflow protection
      "kernel.kptr_restrict" = 1;
      "kernel.perf_event_paranoid" = 3;
    };

    # Audit system (Disabled as it fails on NixOS 26.05 and is redundant hardening)
    # security.auditd.enable = true;


    # DNS configuration (Resolved enabled for caching with basic security)
    services.resolved = {
      enable = true;
      settings = {
        Resolve = {
          DNSSEC = "opportunistic";
          DNSOverTLS = "opportunistic";
        };
      };
    };


    # General system hardening
    boot.tmp.cleanOnBoot = true;
    boot.tmp.useTmpfs = true;

  };
}
