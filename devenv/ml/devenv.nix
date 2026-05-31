{
  pkgs,
  lib,
  config,
  ...
}:
{
  # https://devenv.sh/packages/
  packages = [
    pkgs.python312Packages.numpy
    pkgs.python312Packages.pandas
    pkgs.python312Packages.scipy
    pkgs.python312Packages.matplotlib
    pkgs.python312Packages.scikit-learn
    pkgs.python312Packages.jupyterlab
  ];

  # https://devenv.sh/languages/
  languages = {
    python = {
      enable = true;
      version = "3.12";
    };
  };

  # https://devenv.sh/scripts/
  scripts = {
    notebook.exec = "jupyter lab";
  };

  enterShell = ''
    echo "===================================================="
    echo "🐍 Python Machine Learning & Data Science Shell 🐍"
    echo "===================================================="
    echo "Available libraries:"
    echo "  • NumPy"
    echo "  • Pandas"
    echo "  • SciPy"
    echo "  • Matplotlib"
    echo "  • Scikit-Learn"
    echo "  • JupyterLab"
    echo ""
    echo "💡 Run 'notebook' to launch JupyterLab"
    echo "===================================================="
  '';

  # See full reference at https://devenv.sh/reference/options/
}
