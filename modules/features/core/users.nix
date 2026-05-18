# Flake-parts module exporting user account and shell configuration.
# This sets up the primary user account, fish shell, and SSH agent settings.
{ self, inputs, ... }: {
  flake.nixosModules.users = {
    pkgs,
    config,
    userName,
    userFullName,
    userEmail,
    gitName,
    stateVersion,
    ...
  }: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  documentation.enable = false;
  documentation.nixos.enable = false;

  environment.systemPackages = with pkgs; [
    coreutils
    util-linux
    pciutils
    home-manager
    sops
    age
  ];

  system.stateVersion = stateVersion;

  security = {
    polkit.enable = true;
    rtkit.enable = true;
    sudo = {
      execWheelOnly = true;
      extraConfig = "Defaults insults";
    };
  };

  users.users.${userName} = {
    isNormalUser = true;
    description = userFullName;
    extraGroups = ["networkmanager" "wheel" "video" "render"];
    hashedPasswordFile = config.sops.secrets.user_password.path;
  };


  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit inputs self userName userFullName userEmail gitName; stateVersion = config.system.stateVersion; };
  home-manager.backupFileExtension = "backup";

  home-manager.users.${userName} = {
    home.stateVersion = config.system.stateVersion;
    home.packages = with pkgs; [
      p7zip
      unrar
    ];

    programs.git = {
      lfs.enable = true;
      settings = {
        url."git@github.com:".insteadOf = "https://github.com/";
      };
    };

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {
          addKeysToAgent = "yes";
        };
        "github.com" = {
          hostname = "github.com";
          identityFile = "~/.ssh/id_github";
        };
      };
    };
  };
};
}
