let
  # ── User SSH public keys ──────────────────────────────────────────────
  user_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDTIEhnJwHOKd+RA7DYa2oMJA75UCpOg+szPqlqRkSmk isma";

  # ── Host SSH public keys ──────────────────────────────────────────────
  # Replace with: cat /etc/ssh/ssh_host_ed25519_key.pub  (on each host)
  desktop = "ssh-ed25519 AAAA_REPLACE_WITH_DESKTOP_HOST_KEY root@filosofo-desktop";
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICJDphmjRr4YkhWgPVCj4v/UxKzqZC/PtaO4xHhx+DFD root@filosofo-laptop";

  # ── Key groups ────────────────────────────────────────────────────────
  allUsers = [ user_key ];
  allHosts = [ laptop ]; # Add 'desktop' back once you have its real SSH key
  allKeys = allUsers ++ allHosts;
in
{
  # Encrypted with all keys so any host can decrypt, and you can re-key
  # from your user key.
  "user-password.age".publicKeys = allKeys;
  "github-ssh-key.age".publicKeys = allKeys;
}
