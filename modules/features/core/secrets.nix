# Flake-parts module exporting the Agenix secrets configuration.
# This integrates the encrypted `.age` files into the NixOS system and Home Manager.
# Add new secrets here AND in /secrets.nix (the agenix public-key registry).
{ self, inputs, ... }: {
  flake.nixosModules.secrets = {
    config,
    lib,
    userName,
    ...
  }: let
    # Save the NixOS config to avoid shadowing in the Home Manager submodule
    nixosConfig = config;
  in {
    # ── Identity keys used to decrypt secrets on this host ──────────────
    age.identityPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/home/${userName}/.ssh/id_ed25519"
    ];

    # ── Core System Secrets ──────────────────────────────────────────────
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

    # ── Service Secrets (Relocated to service modules) ───────────────────

    # ── Home Manager User-Level Configuration ────────────────────────────
    home-manager.users.${userName} = { config, ... }: {
      # Symlink the decrypted GitHub SSH key into ~/.ssh/id_github
      home.file.".ssh/id_github" = {
        source = config.lib.file.mkOutOfStoreSymlink nixosConfig.age.secrets.github-ssh-key.path;
      };
    };
  };
}
