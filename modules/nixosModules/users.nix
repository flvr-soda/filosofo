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
  # --------------------------------
  
  # Define the primary user account and its group memberships
  users.users.${userName} = {
    isNormalUser = true;
    description = userFullName;
    extraGroups = ["networkmanager" "wheel"];
    shell = pkgs.fish;
    hashedPasswordFile = config.age.secrets.user-password.path;
  };

  programs.fish.enable = true;
  programs.ssh.startAgent = true;

  # Home Manager User-Level Configuration
  # -------------------------------------
  home-manager.users.${userName} = {
    # Configure Fish shell aliases for system maintenance
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set -g fish_color_autosuggestion brblack
        set -U fish_greeting ""
      '';
      shellAliases = {
        nfup = "nix flake update";
        nfck = "nix flake check";
        nfmt = "nix fmt";
        nfsync = "nix flake update && nix flake check";
        nrepl = "nix repl";
        nsd = "sudo nixos-rebuild switch --flake .#desktop";
        nbd = "sudo nixos-rebuild boot --flake .#desktop";
        ntd = "sudo nixos-rebuild test --flake .#desktop";
        nsl = "sudo nixos-rebuild switch --flake .#laptop";
        nbl = "sudo nixos-rebuild boot --flake .#laptop";
        ntl = "sudo nixos-rebuild test --flake .#laptop";
        nss = "sudo nixos-rebuild switch --flake .#server";
        nbs = "sudo nixos-rebuild boot --flake .#server";
        nts = "sudo nixos-rebuild test --flake .#server";
        ngc = "sudo nix-collect-garbage -d";
        nclean = "sudo nix-collect-garbage -d && nix store gc";
        l = "eza -lh --icons=auto";
        ls = "eza -1 --icons=auto";
        ll = "eza -lha --icons=auto --sort=name --group-directories-first";
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
