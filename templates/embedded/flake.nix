{
  description = "Embedded Systems & Hardware Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    devShells = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          gcc-arm-embedded
          cmake
          openocd
          platformio
          avrdude
          picocom
          gdb
          gnumake
        ];
        
        shellHook = ''
          echo "⚙️ Embedded Systems Environment loaded"
        '';
      };
    });
  };
}
