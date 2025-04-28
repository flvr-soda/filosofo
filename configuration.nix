
{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ 
#      (import .disko.nix{device="dev/nvme0n1";})
      ./hardware-configuration.nix
      ./impermanence.nix
    ];

  nix = {
      settings = {
        experimental-features = ["nix-command" "flakes"];
        auto-optimise-store = true;
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
  };

  nixpkgs.config.allowUnfree = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.kernelModules = ["amdgpu"];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  

  users.users."soda" = {
    isNormalUser = true;
    shell = pkgs.fish;
    initialPassword = "soda";
    extraGroups = [ "wheel" "networkmanager"]; 
  };


  virtualisation.docker.enable = true;
 

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
  programs.fuse.userAllowOther = true;
  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users = {
      "soda" = import ./home.nix;
    };
  };

  security.rtkit.enable = true; 
  # services
  services = {
    upower.enable = true;
    gvfs.enable = true;
    udisks2.enable = true;
    openssh.enable = true;
    blueman.enable = true; 
  # enable sddm as a wayland display manager 
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;

  # Enable printing
    printing.enable = true;

  # enable sound with pipewire
    pipewire ={
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };
  home.packages = with pkgs; [
    #dev
    vscodium
    git
    blender
    #system
    kitty
    btop
    ark
    yazi
    dolphin
    #internet
    qbittorrent
    brave
    #media
    obs-studio
    imv
    ffmpeg
    geeqie
    vlc
    #gaming
    lutris
    bottles
    steam-run
  ];

  networking = {
    hostName = "seizure";
    networkmanager.enable = true;   
  };

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
  
  programs = {
    fish.enable = true;
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };    
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
  };

  # Fonts
  fonts = {
    packages = with pkgs; [
      source-code-pro
      noto-fonts
      noto-fonts-cjk-sans
      twitter-color-emoji
      font-awesome
      powerline-fonts
      nerd-fonts._0xproto
      nerd-fonts.droid-sans-mono
    ];
    fontconfig = {
      hinting.autohint = true;
    };
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSOR = "1";    
  };





  system.stateVersion = "24.11"; # Did you read the comment?
}