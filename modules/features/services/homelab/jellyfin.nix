# jellyfin.nix — Jellyfin media server.
#
# Rules enforced:
#   ✓ Binds globally (openFirewall = true) — no reverse proxy
#   ✓ Jellyfin service user added to 'video' and 'render' groups atomically
#     so it inherits GPU HW-acceleration from core/hardware.nix
#   ✓ Conditional GPU accel: only adds render/video groups when AMD GPU present
{ lib, mediaGroup, mediaPath, ... }: {
  flake.nixosModules.jellyfin = { config, pkgs, ... }:
    let
      cfg   = config.filosofo.features.jellyfin;
      isAmd = config.filosofo.hardware.gpu.type == "amd";
    in
    {
      options.filosofo.features.jellyfin = {
        enable = lib.mkEnableOption "Enable Jellyfin media server";
      };

      config = lib.mkIf cfg.enable {
        services.jellyfin = {
          enable      = true;
          # openFirewall handles port 8096 (HTTP) and 8920 (HTTPS) atomically
          openFirewall = true;
          package     = pkgs.jellyfin;
          user        = "jellyfin";
          group       = "jellyfin";
        };

        # GPU acceleration: add service user to render/video groups only on AMD hosts
        users.users.jellyfin.extraGroups =
          [ mediaGroup ] ++ lib.optionals isAmd [ "render" "video" ];

        # Ensure media group exists (may already be declared by arr-stack)
        users.groups.${mediaGroup} = { };

        # Ensure media path exists with correct ownership
        systemd.tmpfiles.rules = [
          "d ${mediaPath} 0775 jellyfin ${mediaGroup} - -"
        ];
      };
    };
}
