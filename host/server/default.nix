{ pkgs, ... }: {
  # Server-specific NixOS settings go here.
  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "isma";
  };

  services.ollama = {
    enable = true;
    loadModels = [ "tinyllama" "deepseek-r1:1.5b" "qwen3.5" ];
  };
}
