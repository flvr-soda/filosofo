# modules/hosts/installer/default.nix — Declarative Custom Installer
{ self, inputs, ... }: {
  flake.nixosConfigurations.installer = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs self; };
    modules = [
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
      ./_installer.nix
    ];
  };
}
