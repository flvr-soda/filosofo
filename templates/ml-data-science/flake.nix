{
  description = "Machine Learning & Data Science Environment";

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
      pythonEnv = pkgs.python3.withPackages (ps: with ps; [
        jupyterlab
        pytorch
        pandas
        scikit-learn
        matplotlib
        numpy
      ]);
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          pythonEnv
          postgresql
          dvc
          podman
        ];
        
        shellHook = ''
          echo "🧠 Machine Learning & Data Science Environment loaded"
          echo "Use 'jupyter lab' to start your notebooks."
        '';
      };
    });
  };
}
