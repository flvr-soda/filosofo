{
  pkgs,
  lib, 
  ... 
}:{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Nix settings
  nixpkgs.config.allowUnfree = true;
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"]; 
      allowed-users = ["@wheel"]; # Restrict Nix usage to wheel group
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
  # Bluetooth settings
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
  };

  # Graphic settings
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

  # Enable kde desktop environment
  services ={
    desktopManager.plasma6.enable = true;
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true; # For Wayland support
      };
      autoLogin = {
        enable = true;    
        user = "isma"; 
      };
    };
  };

  # Exclude unwanted default kde apps
  environment.plasma6.excludePackages = with pkgs; [
    kdePackages.elisa # Music player
  ];
    
  services.printing.enable = true; # Enable CUPS to print documents.
    
  services.flatpak.enable = true; # nix-flatpak setup

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

  # Users
  users.users.isma = {
    isNormalUser = true;
    description = "Isma";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
  };

  # System programs settings
  programs = {
    fish.enable = true;

    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
    };
  };

  environment ={
    defaultPackages = lib.mkForce []; # Remove default packages

    sessionVariables = {
      NIXOS_OZONE_WL = "1"; # Hint electron apps to use Wayland
      WLR_NO_HARDWARE_CURSORS = "1"; # Disable hardware cursors for better compatibility
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    };
    
    # My system packages
    systemPackages = with pkgs; [
      # Core system utilities
      coreutils
      util-linux
      udiskie
      pciutils
      openssh
      openvpn
      curl
      wget
      # Misc
      vim
      gcc
      home-manager
    ];
  };

  # Ollama as a systemd service for local AI models
  services.ollama = {
    enable = true;
    # Preload models, see https://ollama.com/library
    loadModels = [ "tinyllama" "deepseek-r1:1.5b" "qwen3.5"];
  };

  # Openssh settings
  services.openssh = {
    settings.PermitRootLogin = "no";
    settings.PasswordAuthentication = false;
    allowSFTP = false; # Disable SFTP unless explicitly needed (WHY? IDK)
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
    layout = "latam";
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

  system.stateVersion = "25.05"; # DO NOT CHANGE  F*CK

}
