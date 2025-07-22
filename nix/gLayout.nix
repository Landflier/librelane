{
  lib,
  fetchFromGitHub,
  fetchPypi,
  buildPythonPackage,
  setuptools,
  wheel,
  # Main dependencies
  scipy, 
  numpy,
  pandas,
  matplotlib,
  klayout,  # From nix-eda
  gdstk,
  svgutils,
  gdsfactory,
  # Dev dependencies
  colorama,
  cmd2,
  pytest,
  pytest-cov,
  black,
  isort,
  flake8,
  # ML dependencies
  torch,
  transformers,
  scikit-learn,
  # required by openfasoc/glayout/test_glayout.py
  pyfiglet,
  nltk,
  # required by the jupyter notebooks
  ipywidgets,
  jupytext,
  version ? "0.1.1",
  rev ? "88a787b3a7ba6188f6fbbd166c873e5f029f4016",
  sha256 ? "sha256-+/PLJmgwfTTsh5uoSMvL4NXGNSQ6vQDDImdkuAA1TeU=",
}: let
  prettyprint = buildPythonPackage {
    pname = "prettyprint";
    format = "pyproject";
    version = "0.1.5";

    buildInputs = [
      setuptools
    ];

    src = fetchPypi {
      inherit (prettyprint) pname version;
      sha256 = "sha256-dCMhC2Kt+zd3Z3kUzSXbSRnxwrCvugRUNl/7+j9+NzE=";
    };
    doCheck = false;
  };

  prettyprinttree = buildPythonPackage {
    pname = "prettyprinttree";
    format = "pyproject";
    version = "2.0.1";

    propagatedBuildInputs = [
      colorama
      cmd2
    ];
  
    buildInputs = [
      setuptools
    ];

    src = fetchPypi {
      inherit (prettyprinttree) pname version;
      sha256 = "sha256-wx+ZZr/jEv7/Waq5Aiy862jeW/YOE74ywagYOl/UUnI=";
    };
    doCheck = false;
  };

  self = buildPythonPackage {
    pname = "glayout";
    inherit version;
    format = "setuptools";

    src = fetchFromGitHub {
      owner = "ReaLLMASIC";
      repo = "glayout";
      inherit rev;
      inherit sha256;
    };

    buildInputs = [
      klayout  # From nix-eda overlay
    ];

    propagatedBuildInputs = [
      gdsfactory
      numpy  
      pandas  
      prettyprint
      prettyprinttree
      matplotlib  
      gdstk
      svgutils
      # required by openfasoc/glayout/test_glayout.py
      pyfiglet
      nltk
      # required by the gLayout jupyter notebooks
      ipywidgets
      jupytext
      scipy
    ];

    nativeBuildInputs = [
      setuptools
      wheel
    ];

    passthru.optional-dependencies = {
      dev = [
        pytest  
        pytest-cov  
        black  
        isort  
        flake8  
      ];
      ml = [
        torch  
        transformers  
        scikit-learn  
      ];
    };

    # Temporarily disable checks until all dependencies are available
    doCheck = false;
    pythonImportsCheck = [];

    meta = with lib; {
      description = "A PDK-agnostic layout automation framework for analog circuit design";
      homepage = "https://github.com/ReaLLMASIC/glayout";
      license = licenses.mit;
      maintainers = with maintainers; [ ];
      platforms = platforms.unix;
    };
  };
in
  self 
