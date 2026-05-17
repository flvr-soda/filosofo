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
    # NixOS System-Level Configuration

    # Enable KVM kernel modules for hardware-accelerated virtualization
    boot.kernelModules = [ "kvm-intel" "kvm-amd" ];

    # Enable libvirt with QEMU/KVM backend
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;   # Run QEMU as the user, not root
        swtpm.enable = true; # Virtual TPM support for Windows 11 guests
      };
    };

    # virt-manager requires the spice-vdagent for clipboard and display integration
    virtualisation.spiceUSBRedirection.enable = true;

    # Enable Docker container daemon
    virtualisation.docker = {
      enable = true;
      logDriver = "json-file";
    };

    # Enable lightweight Kubernetes control-plane (k3s) - defaulted to false
    services.k3s = {
      enable = lib.mkDefault false;
      role = "server";
      extraFlags = "--disable traefik --disable local-storage";
    };

    # Add the user to required virtualization and container groups
    users.users.${userName}.extraGroups = [ "libvirtd" "kvm" "docker" ];

    # Home Manager User-Level Configuration
    home-manager.users.${userName} = { pkgs, ... }: {
      home.packages = with pkgs; [
        virt-manager   # GUI frontend for libvirt
        virt-viewer    # Lightweight display viewer for VM consoles
        rustdesk-flutter # Remote desktop utility
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
