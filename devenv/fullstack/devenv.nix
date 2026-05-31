{
  pkgs,
  lib,
  config,
  ...
}:
{
  # https://devenv.sh/packages/
  packages = [
    pkgs.postman
    pkgs.sqlite-interactive
    pkgs.phpPackages.composer
  ];

  # https://devenv.sh/languages/
  languages = {
    python = {
      enable = true;
      venv = {
        enable = true;
      };
    };
    go = {
      enable = true;
    };
    php = {
      enable = true;
    };
  };

  # https://devenv.sh/services/
  services = {
    postgres = {
      enable = true;
      initialDatabases = [
        {
          name = "microservices_dev";
        }
      ];
    };
    mysql = {
      enable = true;
      initialDatabases = [
        {
          name = "laravel_dev";
        }
      ];
    };
  };

  enterShell = ''
    echo "===================================================="
    echo "🛠️ Microservices & API Development Environment"
    echo "===================================================="
    echo "  Python:    $(python --version)"
    echo "  Go:        $(go version)"
    echo "  PHP:       $(php --version)"
    echo "  Composer:  $(composer --version)"
    echo "----------------------------------------------------"
    echo "  PostgreSQL (port 5432, db: microservices_dev)"
    echo "  MySQL (port 3306, db: laravel_dev)"
    echo "  Postman & SQLite CLI also available!"
    echo "===================================================="
  '';

  # See full reference at https://devenv.sh/reference/options/
}
