# security.nix — Threat prevention and system hardening
{ self, inputs, ... }: {
  flake.nixosModules.security = { config, pkgs, lib, ... }: {
    config = {
      # ── Fail2ban: Local pattern-based protection ────────────────────────
      services.fail2ban = {
        enable = true;
        maxretry = 5;
        ignoreIP = [
          "127.0.0.1/8"
          config.filosofo.networking.trustedLanCidr
        ];
      };

      services.crowdsec = {
        enable = true;
        localConfig.acquisitions = [
          {
            source = "journalctl";
            journalctl_filter = [ "_SYSTEMD_UNIT=sshd.service" ];
            labels.type = "syslog";
          }
        ];
      };

      users.users.crowdsec.extraGroups = [ "systemd-journal" ];

      # Ensure logs are persistent for analysis
      environment.systemPackages = [ pkgs.crowdsec ];
    };
  };
}
