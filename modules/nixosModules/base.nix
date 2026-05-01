# Flake-parts module exporting a reusable NixOS module for base system configuration.
# This gets evaluated by import-tree and injected into `flake.nixosModules.base`.
{ self, inputs, ... }: {
  flake.nixosModules.base = {
    pkgs,
    lib,
    inputs,
    userName,
    stateVersion,
    userEmail,
    gitName,
    ...
  }: {
  # NixOS
  nixpkgs.config.allowUnfree = true;
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      allowed-users = ["@wheel"];
      auto-optimise-store = true;
    };
    optimise.automatic = true;
    optimise.dates = ["03:45"];
    gc.automatic = true;
    gc.dates = "weekly";
    gc.options = "--delete-older-than 7d";
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.systemd-boot.enable = true;
    loader.systemd-boot.configurationLimit = 5;
    loader.efi.canTouchEfiVariables = true;
    loader.timeout = 1;
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
  };

  zramSwap.enable = true;
  nixpkgs.overlays = [inputs.antigravity-nix.overlays.default];
  networking.firewall.enable = true;

  security = {
    polkit.enable = true;
    rtkit.enable = true;
    sudo.execWheelOnly = true;
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
      packages = with pkgs; [apparmor-utils apparmor-profiles];
    };
  };

  environment.systemPackages = with pkgs; [
    coreutils
    util-linux
    pciutils
    openssh
    openvpn
    curl
    wget
    home-manager
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
    extraConfig = ''
      AllowTcpForwarding yes
      X11Forwarding no
      AllowAgentForwarding no
      AuthenticationMethods publickey
    '';
  };

  console.keyMap = "la-latin1";
  time.timeZone = "America/Caracas";
  i18n.defaultLocale = "en_US.UTF-8";

  system.stateVersion = stateVersion;

  # Home Manager
  home-manager.users.${userName} = {pkgs, ...}: {
    home.stateVersion = stateVersion;
    home.packages = with pkgs; [
      nixd
      btop
      yazi
      eza
      bat
      ripgrep
      p7zip
      unrar
    ];

    programs = {
      home-manager.enable = true;
      starship = {
        enable = true;
        enableFishIntegration = true;
      };
      fastfetch.enable = true;
      git = {
        enable = true;
        lfs.enable = true;
        settings = {
          user = {
            name = gitName;
            email = userEmail;
          };
          init.defaultBranch = "main";
          url."git@github.com:".insteadOf = "https://github.com/";
        };
      };
    };
  };
};
}
