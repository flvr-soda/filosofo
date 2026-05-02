{ self, inputs, ... }: {
  flake.nixosModules.ssh = { pkgs, ... }: {
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
  };
}
