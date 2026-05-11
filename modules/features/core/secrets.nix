# Flake-parts module: sops-nix secrets (single file: secrets/secrets.yaml).
# Edit with: sops secrets/secrets.yaml
# Add a host: extend .sops.yaml age recipients, then sops updatekeys secrets/secrets.yaml
{ self, inputs, ... }: {
  flake.nixosModules.secrets = {
    config,
    lib,
    userName,
    ...
  }: let
    nixosConfig = config;
  in
  {
    sops.defaultSopsFile = ../../../secrets/secrets.yaml;
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    sops.secrets.user_password = {
      neededForUsers = true;
      mode = "0400";
    };

    sops.secrets.github_ssh_key = {
      owner = userName;
      group = "users";
      mode = "0600";
    };

    home-manager.users.${userName} = { config, ... }: {
      home.file.".ssh/id_github" = {
        source = config.lib.file.mkOutOfStoreSymlink nixosConfig.sops.secrets.github_ssh_key.path;
      };
    };
  };
}
