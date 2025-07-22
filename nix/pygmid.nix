{
  lib,
  fetchFromGitHub,
  fetchPypi,
  buildPythonPackage,
  setuptools,
  flit-core,
  # Standard Python packages
  numpy,
  scipy,
  matplotlib,
  tqdm,
  # Additional dependencies
  arrow,
  six,
}: let
  # Define missing dependencies locally
  # These packages are not available in nixpkgs, so we build them here
  docopt = buildPythonPackage {
    pname = "docopt";
    format = "setuptools";
    version = "0.6.2";

    nativeBuildInputs = [
      setuptools
    ];

    src = fetchPypi {
      inherit (docopt) pname version;
      sha256 = "14f4hn6d1j4b99svwbaji8n2zj58qicyz19mm0x6pmhb50jsics9";
    };
    doCheck = false;
  };

  inform = buildPythonPackage {
    pname = "inform";
    format = "pyproject";
    version = "1.30";

    nativeBuildInputs = [
      setuptools
      flit-core
    ];

    propagatedBuildInputs = [
      arrow
      six
    ];

    src = fetchPypi {
      inherit (inform) pname version;
      sha256 = "0yhk3awnkpca7bf4rsp750b4wjvkdiky4g2zsbd7c2wb0k50hn4s";
    };
    doCheck = false;
  };

  quantiphy = buildPythonPackage {
    pname = "quantiphy";
    format = "pyproject";
    version = "2.20";

    nativeBuildInputs = [
      setuptools
      flit-core
    ];

    src = fetchPypi {
      inherit (quantiphy) pname version;
      sha256 = "0kfqdsgw6fjib69rrz5hqfr83bwam3aqsn4klxvh1ff3ann7alxs";
    };
    doCheck = false;
  };

  ply = buildPythonPackage {
    pname = "ply";
    format = "setuptools";
    version = "3.10";

    nativeBuildInputs = [
      setuptools
    ];

    src = fetchPypi {
      inherit (ply) pname version;
      sha256 = "1jxsr1d2f732r6ljhvm827113dckwl6qwakfvpbdhcbhvpvlmscn";
    };
    doCheck = false;
  };

  psf_utils = buildPythonPackage {
    pname = "psf_utils";
    format = "pyproject";
    version = "1.9";

    nativeBuildInputs = [
      setuptools
      flit-core
    ];

    propagatedBuildInputs = [
      docopt
      inform
      matplotlib
      numpy
      ply
      quantiphy
    ];

    src = fetchPypi {
      inherit (psf_utils) pname version;
      sha256 = "sha256-3vcdFIh5Sm1P+a1roNwrvNRqNbbx1R6rzd4q0cMAy+w=";
    };

    doCheck = false;
  };

# Main pygmid package
in buildPythonPackage {
  pname = "pygmid";
  format = "pyproject";
  version = "1.2.12";

  nativeBuildInputs = [
    setuptools
  ];

  propagatedBuildInputs = [
    numpy
    scipy
    psf_utils
    tqdm
    matplotlib
  ];

  src = fetchFromGitHub {
    owner = "dreoilin";
    repo = "pygmid";
    rev = "4efcd4bd5a1f9f3c47eb3ba7ef609ae031e217f0";
    sha256 = "sha256-YMnHfhWgbULFkbiNu28Zfxti3matAAYp9BaSOwn6O+k=";
  };

  doCheck = false;

  meta = with lib; {
    description = "A python 3 implementation of the gm/ID starter kit";
    longDescription = ''
      pygmid is a Python implementation of the gm/ID starter kit.
      This package provides tools and utilities for analog circuit design
      using the gm/ID methodology for MOSFET characterization.
    '';
    homepage = "https://github.com/dreoilin/pygmid";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.unix;
  };
} 