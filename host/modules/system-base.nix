{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: {
  nixpkgs.config.allowUnfree = true;
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      allowed-users = [ "@wheel" ];
    };

    optimise.automatic = true;
    optimise.dates = [ "03:45" ];
    gc.automatic = true;
    gc.dates = "weekly";
    gc.options = "--delete-older-than 7d";
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  nixpkgs.overlays = [
    inputs.antigravity-nix.overlays.default
  ];

  networking = {
    firewall.enable = true;
  };

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

  # Agenix secrets
  age.secrets.user-password = {
    file = ../secrets/user-password.age;
    owner = "root";
    group = "root";
    mode = "0400";
  };

  users.users.isma = {
    isNormalUser = true;
    description = "Isma";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
    hashedPasswordFile = config.age.secrets.user-password.path;
  };

  programs = {
    fish.enable = true;
  };

  environment = {
    defaultPackages = lib.mkForce [];
    systemPackages = with pkgs; [
      coreutils
      util-linux
      pciutils
      openssh
      openvpn
      curl
      wget
      vim
      home-manager
      inputs.agenix.packages.${pkgs.system}.default
    ];
  };

  services.openssh.enable = true;
  services.openssh.settings = {
    PermitRootLogin = "no";
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
  };
  services.openssh.allowSFTP = false;
  services.openssh.extraConfig = ''
    AllowTcpForwarding yes
    X11Forwarding no
    AllowAgentForwarding no
    AllowStreamLocalForwarding no
    AuthenticationMethods publickey
  '';

  console.keyMap = "la-latin1";

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

  system.stateVersion = "25.05";
}
