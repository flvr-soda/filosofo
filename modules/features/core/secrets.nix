# secrets.nix — User secrets and persistent directories
{ self, inputs, ... }: {
  flake.nixosModules.secrets = { config, userName, ... }: {
    systemd.tmpfiles.rules = [
      "d /home/${userName}/.ssh 0700 ${userName} users - -"
      "d /persist/secrets 0751 root root - -"
    ];
  };
}
