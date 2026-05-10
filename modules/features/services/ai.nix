{ self, lib, ... }:
let
  llmModule =
    { config, pkgs, ... }:
    let
      cfg = config.filosofo.features.llm;
      webUiPort = 8080;
      openLlmPort = 3000;
    in
    {
      options.filosofo.features.llm.enable = lib.mkEnableOption "Enable the local LLM atomic feature";

      config = lib.mkIf cfg.enable {
        # ── Reverse Proxy Registration ──────────────────────────────────────
        filosofo.services.proxy.ai = {
          subdomain = "ai";
          port = webUiPort;
        };

        virtualisation.oci-containers.backend = lib.mkDefault "podman";

        services.ollama = {
          enable = true;
          loadModels = [ "tinyllama" "deepseek-r1:1.5b" "qwen3.5" ];
          # IMPORTANT: By default this runs on CPU! For GPU support, uncomment one of these:
          # package = pkgs.ollama-cuda; # For NVIDIA GPUs
          package = pkgs.ollama-rocm; # For AMD GPUs
        };

        services.open-webui = {
          enable = true;
          port = webUiPort;
          # Caddy reverse-proxies this port, so we don't expose it globally
          openFirewall = false;
        };
      };
    };
in
{
  flake.nixosModules.llm = llmModule;
  flake.nixosModules.ai = llmModule;
}
