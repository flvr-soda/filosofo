{ config, pkgs, inputs, lib, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
    ];


  system.stateVersion = "25.05"; # DON'T CHANGE THIS


  # Nix and nixpkgs settings
  nix.settings.experimental-features = ["nix-command" "flakes"];  
  nix.settings.auto-optimise-store = true;   
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Bootloader and boot options.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  # Networking options
  networking = {
    networkmanager.enable = true;
    hostName = "filosofo";
  };

  virtualisation.docker.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # STYLIX JUNK
  stylix.enable = true;
  stylix.polarity = "dark";
  # stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";

  stylix.base16Scheme = {
    base00 = "282828";
    base01 = "3c3836";
    base02 = "504945";
    base03 = "665c54";
    base04 = "bdae93";
    base05 = "d5c4a1";
    base06 = "ebdbb2";
    base07 = "fbf1c7";
    base08 = "fb4934";
    base09 = "fe8019";
    base0A = "fabd2f";
    base0B = "b8bb26";
    base0C = "8ec07c";
    base0D = "83a598";
    base0E = "d3869b";
    base0F = "d65d0e";
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # User account
  users.users.soda = {
    isNormalUser = true;
    description = "Soda";
    extraGroups = [ "networkmanager" "wheel" ];
  };
  # User with Home Manager
  programs.fuse.userAllowOther = true;
  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users = {
      "soda" = import ./home.nix;
    };
  };

  home-manager.backupFileExtension = ".backup";

  # Program enabling and settings
  programs = {
    firefox.enable = true;

    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    nh = {
      enable = true;
    };
  };

  # Add system packages here
  environment.systemPackages = with pkgs; [ 
    nixd
    obsidian
    qbittorrent-enhanced
    postgresql

    wget
    eza
    cmake
    cava
    btop
    gcc
    neovim

  # KDE
    kdePackages.kcalc
    kdePackages.kcolorchooser
    kdePackages.kolourpaint
    kdePackages.ksystemlog 
    kdePackages.sddm-kcm
    kdiff3
    hardinfo2
    haruna
    wayland-utils
    wl-clipboard  

  # Pen testing pkgs
    metasploit
    sqlmap
    nmap
    burpsuite
    proxychains
    john
    medusa
    theharvester
    wireshark
    wireshark-cli
    aircrack-ng
  ];

  # Graphical settings
  hardware = {    
    enableAllFirmware = true;
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs;[
        vulkan-loader
        vulkan-validation-layers
        vulkan-extension-layer
      ];
    };
  };

  # My services
   services = {
     openssh.enable = true;
     printing.enable = true;
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


}
