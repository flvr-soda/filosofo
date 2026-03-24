{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Nix settings
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"]; 
      allowed-users = ["@wheel"]; # Restrict Nix usage to wheel group
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

  # Bootloader.
  boot ={
    kernelPackages = pkgs.linuxPackages_latest;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  hardware = {
    enableAllFirmware = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  # Networking
  networking = {
    networkmanager.enable = true;
    hostName = "filosofo";
    firewall.enable = true;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.printing.enable = true; # Enable CUPS to print documents.

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
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

  users.users.isma = {
    isNormalUser = true;
    description = "Isma";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
  };

  programs = {
    fish.enable = true;

    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
  };

  environment ={
    defaultPackages = lib.mkForce []; # Remove default packages

    sessionVariables = {
      NIXOS_OZONE_WL = "1"; # Hint electron apps to use Wayland
      WLR_NO_HARDWARE_CURSORS = "1"; # Disable hardware cursors for better compatibility
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    };
    systemPackages = with pkgs; [
      # Core system utilities
      coreutils
      utillinux
      udiskie
      pciutils

      # Networking & security
      openssh
      openvpn
      curl
      wget

      # Cybersecurity
      proxychains
      medusa
      nmap
      whois
      sqlmap
      wireshark
      aircrack-ng

      # Development tools
      vim
      gcc
      nixd
      home-manager
    ];
  };

  # Openssh settings
  services.openssh = {
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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "latam, us";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "la-latin1";

  # Select internationalisation properties.
  time.timeZone = "America/Caracas";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_VE.UTF-8";
    LC_IDENTIFICATION = "es_VE.UTF-8";
    LC_MEASUREMENT = "es_VE.UTF-8";
    LC_MONETARY = "es_VE.UTF-8";
    LC_NAME = "es_VE.UTF-8";
    LC_NUMERIC = "es_VE.UTF-8";
    LC_PAPER = "es_VE.UTF-8";
    LC_TELEPHONE = "es_VE.UTF-8";
    LC_TIME = "es_VE.UTF-8";
  };

  system.stateVersion = "25.05"; # DO NOT CHANGE 

}