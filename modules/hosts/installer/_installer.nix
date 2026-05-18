# modules/hosts/installer/_installer.nix — Custom installer configuration
{ pkgs, inputs, ... }: {
  # target platform
  nixpkgs.hostPlatform = "x86_64-linux";

  # Enable Flakes and nix-commands by default in the live environment
  nix.settings.experimental-features = [ "nix-command" "flakes" ];


  # Define automated installation scripts to format disks and install NixOS in one command
  environment.shellAliases = {
    clone-repo      = "git clone https://github.com/flvr-soda/filosofo.git";
    install-desktop = "sudo nix run github:nix-community/disko/latest -- --mode disko --flake .#desktop && sudo nixos-install --flake .#desktop";
    install-laptop  = "sudo nix run github:nix-community/disko/latest -- --mode disko --flake .#laptop && sudo nixos-install --flake .#laptop";
    install-server  = "sudo nix run github:nix-community/disko/latest -- --mode disko --flake .#server && sudo nixos-install --flake .#server";
  };

  # Console keyboard layout and font
  console = {
    font   = "Lat2-Terminus16";
    keyMap = "us";
  };
}
