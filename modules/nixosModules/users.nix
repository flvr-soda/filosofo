# Flake-parts module exporting user account and shell configuration.
# This sets up the primary user account, fish shell, and SSH agent settings.
{ self, inputs, ... }: {
  flake.nixosModules.users = {
    pkgs,
    config,
    userName,
    userFullName,
    ...
  }: {
  # NixOS System-Level Configuration
  
  # Define the primary user account and its group memberships
  users.users.${userName} = {
    isNormalUser = true;
    description = userFullName;
    extraGroups = ["networkmanager" "wheel"];
    hashedPasswordFile = config.age.secrets.user-password.path;
  };


  programs.ssh.startAgent = true;

  # Home Manager User-Level Configuration
  
  home-manager.users.${userName} = {
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
