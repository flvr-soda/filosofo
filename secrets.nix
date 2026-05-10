let
  # ── User SSH public keys ──────────────────────────────────────────────
  user_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINWMwZE6U49lPtk9b20OpRDgR30tTkZQrFxSbLnfMa2L isma@filosofo";

  # ── Host SSH public keys ──────────────────────────────────────────────
  desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfPpp0tekW+lQWjrNljOp1KJWlxO7FrhTABeYxYQCoq root@filosofo-desktop";
  laptop  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICJDphmjRr4YkhWgPVCj4v/UxKzqZC/PtaO4xHhx+DFD root@filosofo-laptop";
  # server  = "ssh-ed25519 AAAA... root@filosofo-server"; # Add once server is provisioned

  # ── Key groups ────────────────────────────────────────────────────────
  allUsers = [ user_key ];
  allHosts = [ desktop laptop ];
  allKeys  = allUsers ++ allHosts;
in
{
  # ── Core System Secrets ───────────────────────────────────────────────
  # User login password (hashed, used by users.nix hashedPasswordFile)
  "secrets/user-password.age".publicKeys = allKeys;
  # GitHub SSH private key (symlinked into ~/.ssh/id_github by secrets.nix)
  "secrets/github-ssh-key.age".publicKeys = allKeys;

  # ── Service Application Secrets ───────────────────────────────────────
  # Kavita API token key file (required by services.kavita.tokenKeyFile)
  "secrets/kavita-token.age".publicKeys = allKeys;
  # Tailscale auth key for headless node registration (optional)
  "secrets/tailscale-authkey.age".publicKeys = allKeys;
  # Nextcloud initial admin password
  "secrets/nextcloud-admin-password.age".publicKeys = allKeys;
  # Homarr session encryption key (SECRET_ENCRYPTION_KEY env var)
  "secrets/homarr-secret-key.age".publicKeys = allKeys;
  # Navidrome admin credentials
  "secrets/navidrome-password.age".publicKeys = allKeys;
}
