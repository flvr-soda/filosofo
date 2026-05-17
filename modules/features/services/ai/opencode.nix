{ lib, ... }: {
  flake.nixosModules.opencode = { config, pkgs, userName, ... }:
    let
      cfg = config.filosofo.services.ai;
    in
    {
      config = lib.mkIf cfg.local-inference {
        home-manager.users.${userName} = {
          # Configure Antigravity/Agent to use local Ollama
          home.sessionVariables = {
            OLLAMA_HOST = "http://127.0.0.1:11434";
          };
        };
      };
    };
}
