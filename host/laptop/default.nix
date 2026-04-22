{ ... }: {
  imports = [
    ../default.nix
    ./hardware-configuration.nix
  ];

  # Laptop-specific NixOS settings go here.
}
