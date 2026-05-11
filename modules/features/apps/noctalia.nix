{ self, ... }: {
  # Noctalia Shell — Refactored to use wrapped approach from nixconf
  
  flake.nixosModules.noctalia = { config, pkgs, lib, ... }: {
    environment.systemPackages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-shell ];
  };
}
