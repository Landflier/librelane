{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  wheel,
  # Main dependencies
  gdsfactory,
  numpy,
  pandas,
  matplotlib,
  klayout,  # From nix-eda
  gdstk,
  svgutils,
  # Dev dependencies
  pytest,
  pytest-cov,
  black,
  isort,
  flake8,
  # ML dependencies
  torch,
  transformers,
  scikit-learn,
  version ? "0.1.4",
  rev ? "7344b648b999b45ad4d57b750347890144d64207",
  sha256 ? "sha256-5+t6pjfuckz1kKVsMNaUvYcy+ushWFVf7IQC08sN2GM=",
}: let
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
      gdsfactory  # >6.0.0,<=7.7.0
      numpy  # >1.21.0,<=1.24.0
      pandas  # >1.3.0,<=2.3.0
      matplotlib  # >3.4.0,<=3.10.0
      gdstk
      svgutils
    ];

    nativeBuildInputs = [
      setuptools
      wheel
    ];

    passthru.optional-dependencies = {
      dev = [
        pytest  # >=7.0.0
        pytest-cov  # >=3.0.0
        black  # >=22.0.0
        isort  # >=5.0.0
        flake8  # >=4.0.0
      ];
      ml = [
        torch  # >=1.10.0
        transformers  # >=4.0.0
        scikit-learn  # >=1.0.0
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
