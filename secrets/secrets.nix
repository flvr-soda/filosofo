let
  # ── User SSH public keys ──────────────────────────────────────────────
  isma = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDTIEhnJwHOKd+RA7DYa2oMJA75UCpOg+szPqlqRkSmk isma";

  # ── Host SSH public keys ──────────────────────────────────────────────
  # Replace with: cat /etc/ssh/ssh_host_ed25519_key.pub  (on each host)
  desktop = "ssh-ed25519 AAAA_REPLACE_WITH_DESKTOP_HOST_KEY root@desktop";
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICJDphmjRr4YkhWgPVCj4v/UxKzqZC/PtaO4xHhx+DFD root@filosofo";

  # ── Key groups ────────────────────────────────────────────────────────
  allUsers = [ isma ];
  allHosts = [ desktop laptop ];
  allKeys = allUsers ++ allHosts;
in
{
  # Encrypted with all keys so any host can decrypt, and you can re-key
  # from your user key.
  "user-password.age".publicKeys = allKeys;

  # Per-host secrets example (uncomment & create the .age files as needed):
  # "desktop-vpn.age".publicKeys = [ isma desktop ];
  # "laptop-wifi.age".publicKeys = [ isma laptop ];
}
