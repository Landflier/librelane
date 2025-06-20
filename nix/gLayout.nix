{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  wheel,
  numpy,
  pandas,
  matplotlib,
  version ? "0.1.4",
  sha256 ? "sha256-RmsdavfcuKK+wo+q5Db35BXUET+2zS+xZlUJmVvS14g=",
}: let
  self = buildPythonPackage {
    pname = "glayout";
    inherit version;
    format = "setuptools";

    src = fetchFromGitHub {
      owner = "ReaLLMASIC";
      repo = "glayout";
      rev = "main";
      inherit sha256;
    };

    propagatedBuildInputs = [
      numpy
      pandas
      matplotlib
    ];

    nativeBuildInputs = [
      setuptools
      wheel
    ];

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
