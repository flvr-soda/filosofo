{
  username,
  hostname,
  theTimezone,
  theLocale,
  theLCVariables,
  pkgs,
  inputs,
  lib,
  isDesktop,
  isServer,
  ...
}: {
  system.stateVersion = "25.05"; # Do NOT change this

  nixpkgs.config.allowUnfree = true; # Allow unfree packages
  documentation.nixos.enable = false; # Disable documentation

  nix = {
    settings = {
      allowed-users = ["@wheel"]; # Restrict Nix usage to wheel group
      experimental-features = ["nix-command" "flakes"];
      substituters = ["https://hyprland.cachix.org"];
      trusted-substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };

    optimise.automatic = true;
    optimise.dates = ["03:45"];
    gc.automatic = true;
    gc.dates = "weekly";
    gc.options = "--delete-older-than 7d";
  };

  # Bootloader and boot options.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = ["quiet" "splash" "loglevel=3"];
    initrd.systemd.enable = true;
    loader = {
      timeout = 2;
      systemd-boot.configurationLimit = 7;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  # Networking options
  networking = {
    networkmanager.enable = true;
    hostName = "${hostname}";
    firewall.enable = true;
  };

  # Virtualization with Podman
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # Use Podman as a drop-in replacement for Docker
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true; # Enable DNS for containers
  };
  environment.variables.DBX_CONTAINER_MANAGER = "podman";
  users.extraGroups.podman.members = ["${username}"];

  # User account settings
  programs.fuse.userAllowOther = true;
  users = {
    defaultUserShell = pkgs.fish;
    users."${username}" = {
      isNormalUser = true;
      description = "Soda";
      extraGroups = ["networkmanager" "wheel"];
      useDefaultShell = true;
    };
  };

  # Shared program settings
  programs = {
    dconf.enable = true;
    fish.enable = true;

    hyprland = lib.mkIf isDesktop {
      enable = true;
      withUWSM = false;
      xwayland.enable = true;
      package = inputs.hyprland.packages."${pkgs.system}".hyprland;
      portalPackage = inputs.hyprland.packages."${pkgs.system}".xdg-desktop-portal-hyprland;
    };

    steam = lib.mkIf isDesktop {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
  };

  environment = {
    defaultPackages = lib.mkForce []; # Remove default packages

    sessionVariables = {
      NIXOS_OZONE_WL = "1"; # Hint electron apps to use Wayland
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    };

    systemPackages = with pkgs; [
      # Core system utilities
      coreutils
      utillinux
      wayland-utils
      brightnessctl
      udiskie
      ntfs3g
      exfat
      libinput
      lm_sensors
      pciutils

      # Networking & security
      openssh
      openvpn
      curl
      wget

      # Development tools
      cmake
      gcc
      podman-compose
      podman-tui
      distrobox
      nixd
      home-manager
      sops
    ];
  };

  # Graphical settings
  hardware = {
    enableAllFirmware = true;
    graphics = lib.mkIf isDesktop {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        vulkan-loader
        vulkan-validation-layers
        vulkan-extension-layer
      ];
    };
  };

  # Services
  services = {
    displayManager.gdm.enable = lib.mkIf isDesktop true;
    dbus.enable = true;
    upower.enable = true;
    libinput.enable = true;

    udisks2.enable = true;

    tlp = lib.mkIf (!isServer) {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        DISK_IDLE_SECS_ON_AC = 300;
        DISK_IDLE_SECS_ON_BAT = 60;
        USB_AUTOSUSPEND = 1;
        PCIE_ASPM_ON_BAT = "powersave";
        STOP_CHARGE_THRESH_BAT0 = 80;
      };
    };

    openssh = {
      settings.PasswordAuthentication = false;
      allowSFTP = false; # Disable SFTP unless explicitly needed
      settings.kbdInteractiveAuthentication = false;
      extraConfig = ''
        AllowTcpForwarding yes
        X11Forwarding no
        AllowAgentForwarding no
        AllowStreamLocalForwarding no
        AuthenticationMethods publickey
      '';
    };

    xserver = lib.mkIf isDesktop {
      enable = true;
      xkb = {
        layout = "latam,us";
        variant = "";
      };
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };

  # Fonts
  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.hack
      cascadia-code
      noto-fonts-color-emoji
      cm_unicode
      corefonts
    ];
  };

  # Security settings
  security = {
    polkit.enable = true;
    rtkit.enable = true;
    sudo.execWheelOnly = true;
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
      packages = with pkgs; [
        apparmor-utils
        apparmor-profiles
      ];
    };
  };

  # Console keymap
  console.keyMap = "la-latin1";

  # Internationalization settings
  time.timeZone = "${theTimezone}";
  i18n = {
    defaultLocale = "${theLocale}";
    extraLocaleSettings = {
      LC_ADDRESS = "${theLocale}";
      LC_IDENTIFICATION = "${theLCVariables}";
      LC_MEASUREMENT = "${theLCVariables}";
      LC_MONETARY = "${theLCVariables}";
      LC_NAME = "${theLCVariables}";
      LC_NUMERIC = "${theLCVariables}";
      LC_PAPER = "${theLCVariables}";
      LC_TELEPHONE = "${theLCVariables}";
      LC_TIME = "${theLocale}";
    };
  };
}
