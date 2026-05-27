{
  description = "DevOps & Infrastructure Environment";

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
          terraform
          ansible
          
          # Container & Orchestration
          podman
          podman-compose
          kubectl
          kubernetes-helm
          k9s
          
          # CI/CD
          act
          
          # Cloud & Utilities
          awscli2
          jq
          yq
        ];
        
        shellHook = ''
          echo "☁️ DevOps & Infrastructure Environment loaded"
          echo "Tools: kubernetes, podman, terraform, ansible"
        '';
      };
    });
  };
}
