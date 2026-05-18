{ self, inputs, ... }: {
  # Advanced Gaming Module — Ported from nixconf
  # Includes Steam, GameMode, Gamescope, and a robust suite of gaming tools.

  flake.nixosModules.gaming = { config, pkgs, lib, userName, ... }:
    let
      cfg = config.filosofo.features.gaming;
    in
    {
      options.filosofo.features.gaming.enable =
        lib.mkEnableOption "Enable gaming suite";

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
      itch
      dxvk
      gamescope
      mangohud
      r2modman
      heroic
      steamtinkerlaunch
      lsfg-vk
      lsfg-vk-ui
      bastet
      airshipper
      veloren
    ];



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
