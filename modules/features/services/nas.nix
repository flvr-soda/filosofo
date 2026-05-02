{ self, inputs, ... }: {
  flake.nixosModules.nas = { pkgs, config, ... }: {
    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud32;
      hostName = "nextcloud.local";
      config.adminpassFile = "/etc/nextcloud-admin-pass"; # User should create this file
      
      settings = {
        trusted_domains = [ "localhost" ];
      };

      # Use PostgreSQL for better performance in a "powerhouse" setup
      config.dbtype = "pgsql";
      database.createLocally = true;
      
      configureRedis = true;
    };

    # Ensure the admin pass file exists for initial evaluation (empty is fine for now)
    systemd.tmpfiles.rules = [
      "f /etc/nextcloud-admin-pass 0600 nextcloud nextcloud - -"
    ];

    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
