# Flake-parts module exporting the Agenix secrets configuration.
# This integrates the encrypted `.age` files into the NixOS system and Home Manager.
{ self, inputs, ... }: {
  flake.nixosModules.secrets = {
    config,
    userName,
    ...
  }: let
  # Save the NixOS config to avoid shadowing in the Home Manager submodule
  nixosConfig = config;
in {
  # NixOS System-Level Configuration

  # Specify the identity keys used to decrypt the secrets on this host
  age.identityPaths = [
    "/etc/ssh/ssh_host_ed25519_key"
    "/home/${userName}/.ssh/id_ed25519"
  ];

  age.secrets.user-password = {
    file = ../../../secrets/user-password.age;
    owner = "root";
    group = "root";
    mode = "0400";
  };

  age.secrets.github-ssh-key = {
    file = ../../../secrets/github-ssh-key.age;
    owner = userName;
    group = "users";
    mode = "0600";
  };

  # Home Manager User-Level Configuration
  
  home-manager.users.${userName} = {config, ...}: {
    # Symlink the decrypted github SSH key into the user's ~/.ssh directory
    home.file.".ssh/id_github" = {
      # Use nixosConfig to access age secrets
      source = config.lib.file.mkOutOfStoreSymlink nixosConfig.age.secrets.github-ssh-key.path;
    };
  };
};
}
