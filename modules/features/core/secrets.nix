# secrets.nix — Declarative secret management via sops-nix.
#
# Age identity is derived from the SSH host key already persisted at
# /etc/ssh/ssh_host_ed25519_key — zero additional keys to manage.
# All secrets are decrypted at activation time and made available under
# /run/secrets/<name> with correct owner/mode.
{ self, inputs, ... }: {
  flake.nixosModules.secrets = { config, userName, ... }: {
    imports = [ inputs.sops-nix.nixosModules.sops ];

    # Derive the Age identity from the persisted SSH ed25519 host key.
    # Run `ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub` on each host
    # to obtain the public Age key for .sops.yaml.
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    # Single encrypted secrets file committed to the repository.
    sops.defaultSopsFile = "${self}/secrets/secrets.yaml";

    # --- Cryptographic service secrets ---
    # Each entry is decrypted at boot; path available via config.sops.secrets.<name>.path
    sops.secrets."kavita-token" = {
      owner = "kavita";
    };
    sops.secrets."searxng-secret-key" = {
      owner        = "searx";
      # sops writes the raw value; we wrap it in an EnvironmentFile-compatible
      # format by prefixing with SEARXNG_SECRET_KEY= inside secrets.yaml.
    };
    sops.secrets."open-webui-secret-key" = {
      owner = "open-webui";
    };
    sops.secrets."authentik-secret-key" = {
      owner = "authentik";
    };
    sops.secrets."authentik-postgresql-password" = {
      owner = "authentik";
    };

    # --- VPN bootstrap key ---
    sops.secrets."netbird-setup-key" = {
      owner = "root";
      mode  = "0600";
    };

    # Ensure the /persist/secrets directory still exists for passwd files
    # which remain as raw files (hashedPasswordFile is not a sops concern).
    systemd.tmpfiles.rules = [
      "d /home/${userName}/.ssh 0700 ${userName} users - -"
      "d /persist/secrets 0751 root root - -"
    ];
  };
}
