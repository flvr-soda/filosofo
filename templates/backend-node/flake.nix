{
  description = "Node.js Backend & API Development Environment";

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
        config.allowUnfree = true;
      };
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          # Node.js Toolchain
          nodejs
          nodePackages.pnpm
          nodePackages.typescript

          # API Development
          postman
          httpie
          bruno
          jq
          openapi-generator-cli

          # Infrastructure
          postgresql
          redis
          podman
          podman-compose
        ];
        
        shellHook = ''
          echo "🟢 Node.js Backend Environment loaded"
          echo "API Tools: postman, httpie, bruno"
          echo "Infra: podman, kubernetes"
        '';
      };
    });
  };
}
