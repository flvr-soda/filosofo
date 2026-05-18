{ lib, ... }: {
  flake.nixosModules.open-webui = { config, ... }:
    let
      cfg         = config.filosofo.services.ai;
      openWebPort = 8080;
      ollamaPort  = 11434;
    in
    {
      config = lib.mkIf cfg.local-inference {
        services.open-webui = {
          enable = true;
          host   = "0.0.0.0";
          port   = openWebPort;
          environment = {
            OLLAMA_BASE_URL        = "http://127.0.0.1:${builtins.toString ollamaPort}";
            DATABASE_URL           = "postgresql:///open-webui?host=/run/postgresql";
            ENABLE_SIGNUP          = "false";
            DEFAULT_USER_ROLE      = "user";
            ENABLE_RAG_WEB_SEARCH  = "true";
            RAG_WEB_SEARCH_ENGINE  = "searxng";
            SEARXNG_QUERY_URL      = "http://127.0.0.1:8888/search?q=<query>";
          };
        };

        systemd.services.open-webui.serviceConfig.EnvironmentFile = config.sops.secrets.open_webui_secret_key.path;


        sops.secrets.open_webui_secret_key = {
          owner = "open-webui";
          group = "open-webui";
          mode  = "0400";
        };

        networking.firewall.allowedTCPPorts = [ openWebPort ];
      };
    };
}
