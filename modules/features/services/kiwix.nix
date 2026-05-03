{ self, inputs, userName, ... }: {
  flake.nixosModules.kiwix = { pkgs, ... }: {
    # NixOS System-Level Configuration
    
    # We use a custom systemd service to have full control over the powerhouse library
    systemd.services.kiwix-serve = {
      description = "Kiwix Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.kiwix-tools}/bin/kiwix-serve --port 8081 /var/lib/kiwix/*.zim";
        Restart = "always";
        User = "kiwix";
        Group = "kiwix";
        WorkingDirectory = "/var/lib/kiwix";
      };
    };

    users.users.kiwix = {
      isSystemUser = true;
      group = "kiwix";
    };
    users.groups.kiwix = { };

    networking.firewall.allowedTCPPorts = [ 8081 ];

    systemd.tmpfiles.rules = [
      "d /var/lib/kiwix 0755 kiwix kiwix - -"
    ];

    home-manager.users.${userName} = { pkgs, ... }: {
      home.packages = [ pkgs.kiwix ];
    };
  };
}
