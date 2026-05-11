{ lib, pkgs, ... }: {
  # Advanced Power Management Module — Ported from nixconf
  # Integrates power-profiles-daemon with LACT for AMD GPU power profile synchronization.

  flake.nixosModules.powersave = { pkgs, lib, ... }: {
    # mkDefault so a host can opt out (e.g. TLP-only) without merge priority errors
    services.power-profiles-daemon.enable = lib.mkDefault true;
    services.thermald.enable = true;
    powerManagement.powertop.enable = true;

    # LACT (Linux AMDGPU Control Tool) integration
    services.lact.enable = true;

    # Custom service to sync LACT profiles with system power profiles
    systemd.services.lact-monitor = {
      enable = true;
      description = "Monitor PowerProfiles and update LACT profile";
      after = [ "network.target" "lactd.service" "power-profiles-daemon.service" ];
      wants = [ "lactd.service" "power-profiles-daemon.service" ];
      serviceConfig = {
        Type = "simple";
        ExecStartPre = lib.getExe (pkgs.writeShellApplication {
          name = "lact-initial-set";
          runtimeInputs = [ pkgs.lact pkgs.glib pkgs.dbus pkgs.power-profiles-daemon ];
          text = ''
            profile=$(powerprofilesctl get)
            if [[ $profile == "power-saver" ]]; then
                lact cli profile set "power-saver"
            else
                lact cli profile set "default"
            fi
          '';
        });
        ExecStart = lib.getExe (pkgs.writeShellApplication {
          name = "lact-watcher";
          runtimeInputs = [ pkgs.libnotify pkgs.lact pkgs.glib pkgs.dbus ];
          text = ''
            gdbus monitor --system --dest net.hadess.PowerProfiles |
            while read -r line; do
                if [[ $line =~ ActiveProfile ]]; then
                    profile=$(echo "$line" | grep -oP "(?<=<').+?(?='>)")

                    if [[ $profile == "power-saver" ]]; then
                        lact cli profile set "power-saver"
                    else
                        lact cli profile set "default"
                    fi
                fi
            done
          '';
        });
        Restart = "always";
        User = "root";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
