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
      };

      # Ensure logs are persistent for analysis
      environment.systemPackages = [ pkgs.crowdsec ];
    };
  };
}
