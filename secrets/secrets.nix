let
  # ── User SSH public keys ──────────────────────────────────────────────
  user_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINWMwZE6U49lPtk9b20OpRDgR30tTkZQrFxSbLnfMa2L isma@filosofo";

  # ── Host SSH public keys ──────────────────────────────────────────────
  desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfPpp0tekW+lQWjrNljOp1KJWlxO7FrhTABeYxYQCoq root@filosofo-desktop";
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICJDphmjRr4YkhWgPVCj4v/UxKzqZC/PtaO4xHhx+DFD root@filosofo-laptop";

  # ── Key groups ────────────────────────────────────────────────────────
  allUsers = [ user_key ];
  allHosts = [ desktop laptop ];
  allKeys = allUsers ++ allHosts;
in
{
  # Encrypted with all keys so any host can decrypt, and you can re-key
  # from your user key.
  "user-password.age".publicKeys = allKeys;
  "github-ssh-key.age".publicKeys = allKeys;
}
