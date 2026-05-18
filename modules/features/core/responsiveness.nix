# responsiveness.nix — Dynamic process priority management
{ self, inputs, ... }: {
  flake.nixosModules.responsiveness = { config, pkgs, lib, ... }: {
    config = {
      services.ananicy = {
        enable = true;
        package = pkgs.ananicy-cpp;
        rulesProvider = pkgs.ananicy-rules-cachyos;
      };
    };
  };
}
