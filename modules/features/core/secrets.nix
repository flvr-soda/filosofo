# secrets.nix — SOPS-nix configuration and user secrets
{ self, inputs, ... }: {
  flake.nixosModules.secrets = { config, userName, sshKeyName, ... }: {
    imports = [ inputs.sops-nix.nixosModules.default ];

    sops = {
      defaultSopsFile = ../../../secrets/secrets.yaml;
      validateSopsFiles = false;
      age.keyFile = "/persist/var/lib/sops/age/keys.txt";
    };

    sops.secrets.github_ssh_key = {
      path  = "/home/${userName}/.ssh/${sshKeyName}";
      owner = userName;
      mode  = "0400";
    };

    systemd.tmpfiles.rules = [
      "d /home/${userName}/.ssh 0700 ${userName} users - -"
    ];
  };
}
