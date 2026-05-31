{
  pkgs,
  lib,
  config,
  ...
}:
{
  # https://devenv.sh/packages/
  packages = [
    pkgs.pkg-config
    pkgs.libusb1
    pkgs.udev
    pkgs.openblas
    pkgs.probe-rs-tools
    pkgs.espflash
    pkgs.cargo-generate
  ];

  # https://devenv.sh/languages/
  languages.rust = {
    enable = true;
    channel = "stable";
    components = [
      "rustc"
      "cargo"
      "clippy"
      "rustfmt"
      "rust-analyzer"
      "rust-src"
    ];
    targets = [
      "thumbv7m-none-eabi"
      "thumbv7em-none-eabihf"
      "riscv32imac-unknown-none-elf"
    ];
    mold = {
      enable = true;
    };
  };

  # Environment variables for embedded and ML libraries linkage
  env = {
    OPENBLAS_DIR = "${pkgs.openblas}";
  };

  # See full reference at https://devenv.sh/reference/options/
}
