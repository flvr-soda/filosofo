# Flake-parts module exporting KVM/QEMU virtualization support.
# Provides hardware-accelerated virtual machines via libvirt and virt-manager.
# Add this module only to hosts that have hardware virtualization (Intel VT-x / AMD-V).
{ self, inputs, ... }: {
  flake.nixosModules.virtualization = {
    pkgs,
    lib,
    config,
    userName,
    ...
  }:
    let
      cfg = config.filosofo.features.virtualization;
    in
    {
    options.filosofo.features.virtualization.enable =
      lib.mkEnableOption "Enable KVM/QEMU virtualization with libvirt";

    config = lib.mkIf cfg.enable {
    boot.kernelModules = [ "kvm-intel" "kvm-amd" ];

    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;
        swtpm.enable = true; # Required for Windows 11 guest compatibility
      };
    };

    # virt-manager requires the spice-vdagent for clipboard and display integration
    virtualisation.spiceUSBRedirection.enable = true;

    virtualisation.docker = {
      enable = true;
      logDriver = "json-file";
    };

    services.k3s = {
      enable = lib.mkDefault false;
      role = "server";
      extraFlags = "--disable traefik --disable local-storage";
    };

    users.users.${userName}.extraGroups = [ "libvirtd" "kvm" "docker" ];

    # Home Manager User-Level Configuration
    home-manager.users.${userName} = { pkgs, ... }: {
      home.packages = with pkgs; [
        virt-manager
        virt-viewer
        rustdesk-flutter
      ];

      # Persist the default libvirt connection so virt-manager connects automatically
      dconf.settings."org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu:///system" ];
        uris = [ "qemu:///system" ];
      };
    };
    };
  };
}
