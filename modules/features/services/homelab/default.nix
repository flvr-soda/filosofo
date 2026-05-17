# homelab/default.nix — Homelab Master Switch.
# Taxonomy: features/services/homelab/default.nix
#
# Provides a master switch to toggle the entire homelab stack atomically.
# When `filosofo.features.homelab.full-stack.enable` is true, all sub-services
# within this directory are enabled by default (unless explicitly disabled).
{ self, lib, ... }: {
  flake.nixosModules.homelab = { config, ... }:
    let
      cfg = config.filosofo.features.homelab.full-stack;
    in
    {
      imports = [
        self.nixosModules.arr-stack
        self.nixosModules.qbittorrent
        self.nixosModules.jellyfin
        self.nixosModules.navidrome
        self.nixosModules.kavita
        self.nixosModules.kiwix
        self.nixosModules.nextcloud
      ];

      options.filosofo.features.homelab.full-stack.enable =
        lib.mkEnableOption "Enable the full Homelab stack (Media, Arr, Nextcloud, etc.)";

      config = lib.mkIf cfg.enable {
        filosofo.features = {
          arr-stack.enable   = lib.mkDefault true;
          qbittorrent.enable = lib.mkDefault true;
          jellyfin.enable    = lib.mkDefault true;
          navidrome.enable   = lib.mkDefault true;
          kavita.enable      = lib.mkDefault true;
          kiwix.enable       = lib.mkDefault true;
          nextcloud.enable   = lib.mkDefault true;
        };
      };
    };
}
