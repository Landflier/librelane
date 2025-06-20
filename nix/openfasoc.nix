{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
  # Use packages from librelane/nix-eda
  openroad,  # From librelane
  magic-vlsi,  # From nix-eda
  netgen,  # From nix-eda
  yosysFull,  # From nix-eda
  ngspice,  # From nix-eda
  xyce,  # From nix-eda
  makeWrapper,
  gLayout,  # From local nix/gLayout.nix
  klayout,  # From nix-eda
  gdsfactory,  # From nix-eda python packages
}: let
  python-packages = ps: [
    ps.pandas
    ps.numpy
    ps.scipy  
    ps.scikit-learn
    
    # Visualization packages
    ps.matplotlib
    ps.seaborn
    ps.cairosvg
    
    # Template engine
    ps.mako
    
    # Other utilities
    ps.gdsfactory
    ps.nbsphinx
    ps.prettyprinttree
    ps.pyyaml
    gLayout
  ];
  python-env = python3.withPackages python-packages;
in
stdenv.mkDerivation {
  pname = "openfasoc";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "idea-fasoc";
    repo = "OpenFASOC";
    rev = "cf97842e67d19dc7e945beb7ed9eea1d83ba6f89";
    sha256 = "sha256-9ue+Ho7ScySry9s2q4U1KkR2hBMrOZDvhd7+oUe7wHo=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    python-env
    magic-vlsi
    netgen
    yosysFull
    openroad
    ngspice
    xyce
    klayout  
  ];

  installPhase = ''
    mkdir -p $out/bin $out/share/openfasoc
    cp -r * $out/share/openfasoc/
    
    # Create wrapper script
    makeWrapper ${python-env}/bin/python $out/bin/openfasoc \
      --add-flags "$out/share/openfasoc/openfasoc/main.py" \
      --prefix PATH : ${lib.makeBinPath buildInputs}
  '';

  meta = with lib; {
    description = "Fully autonomous synthesis of analog circuits";
    homepage = "https://github.com/idea-fasoc/OpenFASOC";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = [];
  };
} 