{
  pkgs,
  lib,
  config,
  ...
}:
{
  # https://devenv.sh/packages/
  packages = [
    pkgs.arduino-cli
    pkgs.avrdude
    pkgs.picotool
    pkgs.gcc-arm-embedded
    pkgs.openocd-rp2040
    pkgs.platformio
    pkgs.picocom
    pkgs.minicom
    pkgs.cmake
    pkgs.gnumake
  ];

  # https://devenv.sh/languages/
  languages = {
    c = {
      enable = true;
    };
  };

  # Set up convenient environment variables for embedded development
  env = {
    ARDUINO_DIRECTORIES_DATA = "${config.env.DEVENV_STATE}/arduino15";
    ARDUINO_DIRECTORIES_DOWNLOADS = "${config.env.DEVENV_STATE}/arduino15/staging";
    ARDUINO_DIRECTORIES_USER = "${config.env.DEVENV_ROOT}/Arduino";
  };

  # Handy helper scripts for common microcontroller tasks
  scripts = {
    arduino-init = {
      exec = ''
        arduino-cli config init --dest-dir "$ARDUINO_DIRECTORIES_DATA" --overwrite
        arduino-cli core update-index
      '';
    };
    serial-mon = {
      exec = ''
        if [ -z "$1" ]; then
          echo "Usage: serial-mon <port> [baudrate]"
          echo "Example: serial-mon /dev/ttyACM0 115200"
          exit 1
        fi
        baud=''${2:-115200}
        picocom -b "$baud" "$1"
      '';
    };
  };

  enterShell = ''
    echo "⚡ Embedded Engineering Dev Shell Active ⚡"
    echo "Available tooling:"
    echo "  - arduino-cli       : Arduino Command Line Interface"
    echo "  - picotool          : Raspberry Pi RP2040/RP2350 flashing/inspection"
    echo "  - avrdude           : AVR program uploader"
    echo "  - platformio        : Ecosystem for IoT development"
    echo "  - arm-none-eabi-gcc : Bare-metal ARM compiler"
    echo "  - openocd           : Debugger interface"
    echo "  - picocom / minicom : Serial terminal tools"
    echo ""
    echo "Run 'arduino-init' to configure and update the local arduino-cli index."
    echo "Run 'serial-mon <port>' to quickly listen to serial outputs."
  '';

  # See full reference at https://devenv.sh/reference/options/
}
