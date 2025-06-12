{
  username,
  hostname,
  theTimezone,
  theLocale,
  theLCVariables,
  pkgs,
  inputs,
  ...
}: {
  imports = [
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

  nixpkgs.config.allowUnfree = true; # Allow unfree packages

  documentation.nixos.enable = false; # No documentation

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
    hostName = "${hostname}";
  };

  # VIRTUALIZATION WITH DOCKER JUNK
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  services.xserver.enable = true; # Enable the X11 windowing system.

  # Enable the Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # User account
  users.users."${username}" = {
    isNormalUser = true;
    description = "Soda";
    extraGroups = ["networkmanager" "wheel" "docker"];
  };

  # User with Home Manager
  programs.fuse.userAllowOther = true;
#  home-manager = {
#    extraSpecialArgs = {inherit inputs;};
#    users = {
#      "soda" = import ./home.nix;
#    };
#  };

  # Program enabling and settings
  programs = {
    firefox.enable = true;

    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
  };

  # Add system packages here
  environment.systemPackages = with pkgs; [
    nixd
    obsidian
    qbittorrent-enhanced
    bottles
    vscode

    # Cli tools
    wget
    neofetch
    eza
    cmake
    cava
    btop
    gcc
    neovim
    base16-schemes

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
      extraPackages = with pkgs; [
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

  environment.sessionVariables.NIXOS_OZONE_WL = "1"; # Hint electron apps to use wayland

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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "latam";
    variant = "";
  };

  console.keyMap = "la-latin1"; # Configure console keymap

  # Select internationalisation properties.
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
