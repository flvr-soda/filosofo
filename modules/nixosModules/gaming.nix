# Flake-parts module exporting gaming configuration.
# This sets up Steam, proton variants, and wine for the user.
{ self, inputs, ... }: {
  flake.nixosModules.gaming = {
    pkgs,
    userName,
    ...
  }: {
  # NixOS System-Level Configuration
  # --------------------------------
  
  # Enable Steam and open required firewall ports for Remote Play and local transfers
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extraCompatPackages = with pkgs; [proton-ge-bin];
  };

  # Home Manager User-Level Configuration
  # -------------------------------------
  home-manager.users.${userName} = {pkgs, ...}: {
    # Install Wine and Proton tools for non-Steam gaming
    home.packages = with pkgs; [
      wine
      protonup-ng
      winetricks
      bottles
    ];
  };
};
}
