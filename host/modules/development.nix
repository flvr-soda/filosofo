{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    postgresql
    gcc
    gnumake
    cmake
    pkg-config
    openjdk
    python3
    nodejs
  ];

  # Shared development ergonomics for dev machines.
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql;
    ensureDatabases = [ "isma" "isma_dev" ];
    ensureUsers = [
      {
        name = "isma";
        ensureDBOwnership = true;
      }
    ];
  };
}
