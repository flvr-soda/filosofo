{ self, inputs, ... }: {
  # Advanced Gaming Module — Ported from nixconf
  # Includes Steam, GameMode, Gamescope, and a robust suite of gaming tools.

  flake.nixosModules.gaming = { config, pkgs, lib, userName, ... }:
    let
      cfg = config.filosofo.features.gaming;
    in
    {
      options.filosofo.features.gaming.enable =
        lib.mkEnableOption "Enable gaming suite (Steam, Wine, Lutris, Gamescope)";

      config = lib.mkIf cfg.enable {
    hardware.graphics.enable = lib.mkDefault true;

    programs = {
      gamemode.enable = true;
      gamescope.enable = true;
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        protontricks.enable = true;
        extraCompatPackages = with pkgs; [ proton-ge-bin ];
      };
    };

    environment.systemPackages = with pkgs; [
      lutris
      steam-run
      dxvk
      gamescope
      mangohud
      r2modman
      heroic
      er-patcher
      bottles
      steamtinkerlaunch
      prismlauncher
      lsfg-vk
      lsfg-vk-ui
    ];

    # Cache substituters for nix-gaming
    nix.settings = {
      substituters = [ "https://nix-gaming.cachix.org" ];
      trusted-public-keys = [ "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" ];
    };

    home-manager.users.${userName} = { pkgs, ... }: {
      home.packages = with pkgs; [
        wine
        protonup-ng
        winetricks
      ];
    };
      };
    };

}
