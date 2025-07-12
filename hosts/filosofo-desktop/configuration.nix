{
  username,
  hostname,
  theTimezone,
  theLocale,
  theLCVariables,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "25.05"; # For the life of you, do NOT change this shit

  nixpkgs.config.allowUnfree = true; # Allow unfree packages
  documentation.nixos.enable = false; # No documentation

  nix = {
    settings = {
      allowed-users = ["@wheel"]; # Only wheel users get access to nix
      experimental-features = ["nix-command" "flakes"];
      # Cachix
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

  # VIRTUALIZATION WITH PODMAN
  virtualisation.podman = {
    enable = true;
    # Create a `docker` alias for podman, to use it as a drop-in replacement
    dockerCompat = true;
    dockerSocket.enable = true;
    # Required for containers under podman-compose to be able to talk to each other.
    defaultNetwork.settings.dns_enabled = true;
  };
  environment.variables.DBX_CONTAINER_MANAGER = "podman";
  users.extraGroups.podman.members = ["${username}"];

  # System wide stylix
  stylix.enable = true;
  stylix.polarity = "dark";
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-soft.yaml";

  # User account
  programs.fuse.userAllowOther = true;
  users.users."${username}" = {
    isNormalUser = true;
    description = "Soda";
    extraGroups = ["networkmanager" "wheel"];
  };

  # Program enabling and settings
  programs = {
    dconf.enable = true;

    hyprland = {
      enable = true;
      withUWSM = false;
      xwayland.enable = true;
      package = inputs.hyprland.packages."${pkgs.system}".hyprland;
      portalPackage = inputs.hyprland.packages."${pkgs.system}".xdg-desktop-portal-hyprland;
    };

    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1"; # Hint electron apps to use wayland
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };

  environment.defaultPackages = lib.mkForce []; # remove default packages

  environment.systemPackages = with pkgs; [
    # Core system utilities
    coreutils
    utillinux
    wayland-utils # Important for Wayland debugging/info

    # Networking & Security
    openssh
    openvpn
    curl
    wget

    # Development Tools
    cmake
    gcc
    podman-compose
    podman-tui
    distrobox
    nixd
    home-manager # Keep home-manager here as it's a system-level tool managing user configs
    sops
  ];

  # Graphical settings
  hardware = {
    enableAllFirmware = true;
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        vulkan-loader
        vulkan-validation-layers
        vulkan-extension-layer
      ];
    };
  };

  # Enable the Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.printing.enable = true;
  services.xserver.enable = true; # Enable the X11 windowing system.
  services.upower.enable = true;

  services.openssh = {
    settings.PasswordAuthentication = false;
    allowSFTP = false; # Don't set this if you need sftp
    settings.kbdInteractiveAuthentication = false;
    extraConfig = ''
      AllowTcpForwarding yes
      X11Forwarding no
      AllowAgentForwarding no
      AllowStreamLocalForwarding no
      AuthenticationMethods publickey
    '';
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    cm_unicode
    corefonts
  ];

  security = {
    sudo.execWheelOnly = true; # Limit sudo usage to user in the wheel group
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
      packages = with pkgs; [
        apparmor-utils
        apparmor-profiles
      ];
    };
  };

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "latam";
    variant = "";
  };

  console.keyMap = "la-latin1"; # Configure console keymap

  # Internationalisation properties.
  time.timeZone = "${theTimezone}";
  i18n.defaultLocale = "${theLocale}";
  i18n.extraLocaleSettings = {
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
}
