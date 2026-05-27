{
  # modules/templates/default.nix
  # Follows the dendritic pattern by exposing flake templates via the module tree
  # rather than hardcoding them in flake.nix.

  flake.templates = {
    backend-rust = {
      path = ../../templates/backend-rust;
      description = "Rust Backend & API Development Environment";
    };
    backend-node = {
      path = ../../templates/backend-node;
      description = "Node.js Backend & API Development Environment";
    };
    backend-go = {
      path = ../../templates/backend-go;
      description = "Go Backend & API Development Environment";
    };
    backend-python = {
      path = ../../templates/backend-python;
      description = "Python Backend & API Development Environment";
    };
    frontend = {
      path = ../../templates/frontend;
      description = "Frontend Development Environment";
    };
    ml-data-science = {
      path = ../../templates/ml-data-science;
      description = "Machine Learning & Data Science Environment";
    };
    embedded = {
      path = ../../templates/embedded;
      description = "Embedded Systems & Hardware Development Environment";
    };
    devops = {
      path = ../../templates/devops;
      description = "DevOps & Infrastructure Environment";
    };
  };
}
