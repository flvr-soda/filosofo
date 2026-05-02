# Flake-parts module exporting AI service configuration.
# This provides the Ollama service for running local LLMs.
{ self, inputs, ... }: {
  flake.nixosModules.ai = {
    pkgs,
    ...
  }: {
    # NixOS System-Level Configuration
    
    # Enable and configure the Ollama service
    services.ollama = {
      enable = true;
      # Load models on startup for convenience
      loadModels = [ "tinyllama" "deepseek-r1:1.5b" "qwen3.5" ];
    };

    # Enable Open WebUI for a beautiful frontend that supports local and API-based models
    services.open-webui = {
      enable = true;
      port = 8080;
      openFirewall = true;
    };
  };
}
