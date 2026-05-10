{ ... }: {
  flake.nixosModules.pipewire = { pkgs, ... }: {
    # PipeWire audio stack — replaces PulseAudio entirely
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # Explicitly disable PulseAudio to avoid conflicts
    services.pulseaudio.enable = false;

    environment.systemPackages = with pkgs; [
      pavucontrol # GUI volume mixer
      wireplumber # Session manager
    ];
  };
}
