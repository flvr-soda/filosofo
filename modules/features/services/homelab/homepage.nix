{ lib, ... }: {
  flake.nixosModules.homepage = { config, ... }:
    let
      cfg = config.filosofo.features.homepage;
    in
    {
      options.filosofo.features.homepage = {
        enable = lib.mkEnableOption "Enable Homepage Dashboard";
      };

      config = lib.mkIf cfg.enable {
        services.homepage-dashboard = {
          enable = true;
          listenPort = 3001;
          settings = {
            background = "https://images.unsplash.com/photo-1507525428034-b723cf961d3e";
          };
          services = [
            {
              "Media & Entertainment" = [
                { "Jellyfin" = { icon = "jellyfin"; href = "http://localhost:8096"; }; }
                { "Navidrome" = { icon = "navidrome"; href = "http://localhost:4533"; }; }
                { "Kavita" = { icon = "kavita"; href = "http://localhost:5000"; }; }
                { "Kiwix" = { icon = "kiwix"; href = "http://localhost:8081"; }; }
              ];
            }
            {
              "Arr Stack" = [
                { "Sonarr" = { icon = "sonarr"; href = "http://localhost:8989"; }; }
                { "Radarr" = { icon = "radarr"; href = "http://localhost:7878"; }; }
                { "Lidarr" = { icon = "lidarr"; href = "http://localhost:8686"; }; }
                { "Prowlarr" = { icon = "prowlarr"; href = "http://localhost:9696"; }; }
                { "Bazarr" = { icon = "bazarr"; href = "http://localhost:6767"; }; }
                { "Jellyseerr" = { icon = "jellyseerr"; href = "http://localhost:5055"; }; }
              ];
            }
            {
              "Productivity & Data" = [
                { "Nextcloud" = { icon = "nextcloud"; href = "http://localhost:80"; }; }
                { "Paperless-ngx" = { icon = "paperless"; href = "http://localhost:28981"; }; }
                { "Immich" = { icon = "immich"; href = "http://localhost:2283"; }; }
                { "Vaultwarden" = { icon = "vaultwarden"; href = "http://localhost:8222"; }; }
              ];
            }
            {
              "AI & Search" = [
                { "Open-WebUI" = { icon = "open-webui"; href = "http://localhost:8080"; }; }
                { "SearXNG" = { icon = "searxng"; href = "http://localhost:8888"; }; }
              ];
            }
            {
              "Security & Infrastructure" = [
                { "Authentik" = { icon = "authentik"; href = "http://localhost:9000"; }; }
              ];
            }
          ];
        };
      };
    };
}
