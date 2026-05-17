{ lib, ... }: {
  flake.nixosModules.ollama = { config, pkgs, ... }:
    let
      cfg = config.filosofo.services.ai;
      isAmd = config.filosofo.hardware.gpu.type == "amd";
      ollamaPort = 11434;
    in
    {
      options.filosofo.services.ai = {
        local-inference = lib.mkEnableOption "Enable local AI inference suite";
        
        forceCpu = lib.mkOption {
          type = lib.types.bool;
          default = false; 
          description = "Force CPU execution even if an AMD/Nvidia GPU is detected. Ideal for unsupported legacy GPUs.";
        };
        
        models = lib.mkOption {
          type    = with lib.types; listOf str;
          # Swapped to Llama 3.1 (8B) for heavy lifting and Llama 3.2 (3B) for raw speed
          default = [ "llama3.1" "llama3.2" ];
          description = "Models to pre-load into Ollama on startup.";
        };
        
        contextSize = lib.mkOption {
          type    = lib.types.int;
          default = 8192; 
          description = "Default context window size in tokens (OLLAMA_NUM_CTX).";
        };
      };

      config = lib.mkIf cfg.local-inference {
        services.ollama = {
          enable = true;
          package = if (isAmd && !cfg.forceCpu) then pkgs.ollama-rocm else pkgs.ollama;
          host    = "0.0.0.0";
          port    = ollamaPort;
          loadModels = cfg.models;
          
          environmentVariables = {
            OLLAMA_NUM_CTX = builtins.toString cfg.contextSize;
          } // lib.optionalAttrs (isAmd && !cfg.forceCpu) {
            ROCR_VISIBLE_DEVICES = "0";
            HSA_OVERRIDE_GFX_VERSION = "11.0.0"; 
          };
        };
        
        networking.firewall.allowedTCPPorts = [ ollamaPort ];
        
        nix.settings = {
          substituters      = [ "https://nixpkgs-unfree.cachix.org" ];
          trusted-public-keys = [
            "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxRDkznGAihCABYrCKCh0="
          ];
        };
      };
    };
}