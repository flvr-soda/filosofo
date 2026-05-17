# secrets.nix — SOPS-nix configuration and user secrets
{ self, inputs, ... }: {
  flake.nixosModules.secrets = { config, userName, ... }: {
    imports = [ inputs.sops-nix.nixosModules.default ];

    sops = {
      defaultSopsFile = ../../../secrets/secrets.yaml;
      validateSopsFiles = false;
      age.keyFile = "/persist/var/lib/sops/age/keys.txt";
    };

    sops.secrets.user_password.neededForUsers = true;

    sops.secrets.github_ssh_key = {
      path  = "/home/${userName}/.ssh/id_github";
      owner = userName;
      mode  = "0400";
    };

    systemd.tmpfiles.rules = [
      "d /home/${userName}/.ssh 0700 ${userName} users - -"
    ];
  };
}
