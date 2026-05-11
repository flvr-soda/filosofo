{ lib, ... }: {
  flake.nixosModules.services-base = { config, pkgs, ... }: {
    options.filosofo.services.proxy = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to enable this proxy entry";
          };
          subdomain = lib.mkOption {
            type = lib.types.str;
            description = "The subdomain to use (e.g. 'cloud' for cloud.filosofo.lan)";
          };
          port = lib.mkOption {
            type = lib.types.port;
            description = "The internal port to proxy to";
          };
        };
      });
      default = { };
      description = "Declarative reverse proxy registrations for Caddy";
    };
    config = {
      services.upower.enable = true;
    };
  };
}

