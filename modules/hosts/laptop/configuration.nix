# laptop/configuration.nix — Portable Workstation
{ self, inputs, ... }: {
  flake.nixosModules.laptopConfiguration = { lib, pkgs, hostPrefix, ... }: {
    imports =
      [
        self.nixosModules.laptopHardware
        self.nixosModules.core
        self.nixosModules.ui
        self.nixosModules.dev-tools
        self.nixosModules.toolchains
        self.nixosModules.engineering
        self.nixosModules.gaming
        self.nixosModules.browsers
        self.nixosModules.media
        self.nixosModules.productivity
        self.nixosModules.tailscale
        self.nixosModules.virtualization
        # AI and DB are accessed remotely via Tailscale — not run locally, but module is included just in case
        self.nixosModules.ollama
        self.nixosModules.open-webui
        self.nixosModules.opencode
        # Declaration of Disko layout using the single-SSD laptop blueprint.
        ./_disko.nix
      ];

    networking.hostName = "${hostPrefix}-laptop";

    filosofo.hardware = {
      gpu.type     = "amd";
      powerProfile = "powersave";
    };

    filosofo.features = {
      desktop.niri.enable             = lib.mkDefault true;
      dev-tools.enable                = lib.mkDefault true;
      toolchains.enable               = lib.mkDefault true;
      engineering.enable              = lib.mkDefault false;
      browsers.enable                 = lib.mkDefault true;
      media.enable                    = lib.mkDefault true;
      productivity.enable             = lib.mkDefault true;
      gaming.enable                   = lib.mkDefault true;
      virtualization.enable           = lib.mkDefault true;
      tailscale.enable                = lib.mkDefault true;
    };
    filosofo.services.ai.local-inference = lib.mkDefault false;
  };
}
