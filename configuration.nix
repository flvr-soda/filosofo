{
  username,
  hostname,
  theTimezone,
  theLocale,
  theLCVariables,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "25.05"; # DON'T CHANGE THIS

  # Nix and nixpkgs settings
  nixpkgs.config.allowUnfree = true; # Allow unfree packages
  nix.settings.allowed-users = ["@wheel"]; # Only wheel users get access to nix
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.optimise.automatic = true;
  nix.optimise.dates = ["03:45"];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  documentation.nixos.enable = false; # No documentation

  # Bootloader and boot options.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
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

  # VIRTUALIZATION WITH DOCKER JUNK
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  stylix.enable = true;
  stylix.polarity = "dark";
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

  # User account
  users.users."${username}" = {
    isNormalUser = true;
    description = "Soda";
    extraGroups = ["networkmanager" "wheel" "docker"];
  };
  programs.fuse.userAllowOther = true;

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

  environment.sessionVariables.NIXOS_OZONE_WL = "1"; # Hint electron apps to use wayland

  environment.defaultPackages = lib.mkForce []; # remove default packages like perl and rsync

  # Add system packages here
  environment.systemPackages = with pkgs; [
    # Desktop apps
    obsidian
    qbittorrent-enhanced
    vscode
    wine
    kitty

    # Cli tools
    nixd
    nano
    wget
    home-manager
    sops
    fastfetch
    eza
    cmake
    cava
    btop
    gcc
    base16-schemes
    wayland-utils
    wl-clipboard

    # Cybersecurity stuff
    clamav
    wireshark
    burpsuite
    metasploit
    sqlmap
    nmap
    proxychains
    john
    medusa
    theharvester
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

  # Enable the Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.printing.enable = true;
  services.xserver.enable = true; # Enable the X11 windowing system.

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

  security.sudo.execWheelOnly = true; # Limit sudo usage to user in the wheel group

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
