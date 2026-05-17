# searxng.nix — Private web search engine
{ self, inputs, lib, ... }: {
  flake.nixosModules.searxng = { config, pkgs, ... }:
    let
      cfg = config.filosofo.services.searxng;
      port = 8888;
    in
    {
      options.filosofo.services.searxng.enable =
        lib.mkEnableOption "Enable SearXNG private search engine";

      config = lib.mkIf cfg.enable {
        services.searx = {
          enable = true;
          package = pkgs.searxng;
          redisCreateLocally = true; # Use local redis for search results caching
          
          settings = {
            server = {
              inherit port;
              bind_address = "0.0.0.0";
              secret_key = "@SEARXNG_SECRET_KEY@"; # Replaced by EnvironmentFile
            };
            search = {
              safe_search = 1;
              autocomplete = "google";
            };
            engines = [
              { name = "google"; engine = "google"; shortcut = "go"; }
              { name = "bing"; engine = "bing"; shortcut = "bi"; }
              { name = "duckduckgo"; engine = "duckduckgo"; shortcut = "ddg"; }
              { name = "wikipedia"; engine = "wikipedia"; shortcut = "wi"; }
            ];
          };
        };

        # Load the secret key from sops
        systemd.services.searx.serviceConfig.EnvironmentFile = config.sops.secrets.searxng_secret_key.path;

        sops.secrets.searxng_secret_key = {
          owner = "searx";
          group = "searx";
          mode  = "0400";
        };

        networking.firewall.allowedTCPPorts = [ port ];
      };
    };
}
