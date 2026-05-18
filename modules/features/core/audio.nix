# core/audio.nix — Core system audio via Pipewire
# Enforces system audio hardware daemon rules.
{ lib, ... }: {
  flake.nixosModules.audio = { config, pkgs, ... }: {
    options.filosofo.core.audio = {
      enable = lib.mkEnableOption "Enable core system audio infrastructure";
    };

    config = lib.mkIf config.filosofo.core.audio.enable {
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
        
        # Integrates real-time microphone noise cancellation.
        # DeepFilterNet provides low-latency deep learning noise suppression.
        extraConfig = {
          pipewire."99-input-denoising" = {
            "context.modules" = [
              {
                "name" = "libpipewire-module-filter-chain";
                "args" = {
                  "node.description" = "DeepFilter Noise Cancelling Source";
                  "media.name" = "DeepFilter Noise Cancelling Source";
                  "filter.graph" = {
                    "nodes" = [
                      {
                        "type" = "ladspa";
                        "name" = "DeepFilter Mono";
                        "plugin" = "${pkgs.deepfilternet}/lib/ladspa/libdeep_filter_ladspa.so";
                        "label" = "deep_filter_mono";
                      }
                    ];
                  };
                  "audio.rate" = 48000;
                  "capture.props" = {
                    "node.name" = "deep_filter_mono_input";
                    "node.passive" = true;
                  };
                  "playback.props" = {
                    "node.name" = "deep_filter_mono_output";
                    "media.class" = "Audio/Source";
                  };
                };
              }
            ];
          };
        };
      };

      # Conflict prevention: ensure traditional PulseAudio daemon is disabled.
      services.pulseaudio.enable = false;
    };
  };
}
