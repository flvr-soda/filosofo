{ self, inputs, ... }: {
  # Advanced Gaming Module — Ported from nixconf
  # Includes Steam, GameMode, Gamescope, and a robust suite of gaming tools.

  flake.nixosModules.gaming = { pkgs, lib, userName, ... }: {
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
      self.packages.${pkgs.stdenv.hostPlatform.system}.wow-launcher
    ];

    # Cache substituters for nix-gaming
    nix.settings = {
      substituters = [ "https://nix-gaming.cachix.org" ];
      trusted-public-keys = [ "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" ];
    };

    # Non-Steam gaming tools in Home Manager
    home-manager.users.${userName} = { pkgs, ... }: {
      home.packages = with pkgs; [
        wine
        protonup-ng
        winetricks
      ];
    };
  };

  perSystem = { pkgs, ... }: {
    packages.wow-launcher = pkgs.writeShellApplication {
      name = "wow-launcher";
      runtimeInputs = with pkgs; [
        inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.wine-tkg
        winetricks
        vulkan-loader
        dxvk
      ];
      text = ''
        export WINEPREFIX="$HOME/Games/Wow"
        export WINEARCH=win64
        export WINEDEBUG="-all"
        export DRI_PRIME=1
        export DXVK_HUD=1
        export DXVK_DEVICE_SELECT=1

        BNET_EXE="$WINEPREFIX/drive_c/Program Files (x86)/Battle.net/Battle.net.exe"
        WOW_EXE="$WINEPREFIX/drive_c/Program Files (x86)/World of Warcraft/_retail_/Wow.exe"
        INSTALLER="Battle.net-Setup.exe"

        if [ ! -d "$WINEPREFIX" ]; then
          echo "Initializing new Wine prefix..."
          mkdir -p "$WINEPREFIX"
          wineboot -u
        fi

        if [ -f "$WOW_EXE" ]; then
          echo "Launching WoW via DXVK..."
          wine "$WOW_EXE"
          exit 0
        fi

        if [ ! -f "$BNET_EXE" ]; then
          if [ -f "$INSTALLER" ]; then
            wine "$INSTALLER"
          else
            echo "Installer not found. Please download Battle.net-Setup.exe"
            exit 1
          fi
        else
          wine "$BNET_EXE"
        fi
      '';
    };
  };
}
