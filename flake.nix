# Copyright 2025 LibreLane Contributors
#
# Adapted from OpenLane
#
# Copyright 2023 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
{
  description = "open-source infrastructure for implementing chip design flows";

  inputs = {
    nix-eda.url = "github:fossi-foundation/nix-eda/2.1.3";
    libparse.url = "github:efabless/libparse-python";
    ciel.url = "github:fossi-foundation/ciel";
    devshell.url = "github:numtide/devshell";
    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
  };

  inputs.ciel.inputs.nix-eda.follows = "nix-eda";
  inputs.devshell.inputs.nixpkgs.follows = "nix-eda/nixpkgs";
  inputs.libparse.inputs.nixpkgs.follows = "nix-eda/nixpkgs";

  outputs = {
    self,
    nix-eda,
    libparse,
    ciel,
    devshell,
    ...
  }: let
    nixpkgs = nix-eda.inputs.nixpkgs;
    lib = nixpkgs.lib;
  in {
    # Common
    overlays = {
      default = lib.composeManyExtensions [
        (import ./nix/overlay.nix)
        (nix-eda.flakesToOverlay [libparse ciel])
        (pkgs': pkgs: {
          yosys-sby = (pkgs.yosys-sby.override { sha256 = "sha256-Il2pXw2doaoZrVme2p0dSUUa8dCQtJJrmYitn1MkTD4="; });
          yosys = pkgs.yosys.overrideAttrs(old: {
            patches = old.patches ++ [
              ./nix/patches/yosys/async_rules.patch
            ];
          });
        })
        (
          pkgs': pkgs: let
            callPackage = lib.callPackageWith pkgs';
          in {
            colab-env = callPackage ./nix/colab-env.nix {};
            opensta = callPackage ./nix/opensta.nix {};
            openroad-abc = callPackage ./nix/openroad-abc.nix {};
            openroad = callPackage ./nix/openroad.nix {};
            openfasoc = callPackage ./nix/openfasoc.nix {
              inherit (pkgs') openroad;
              inherit (nix-eda.legacyPackages.${pkgs.system}) 
                magic-vlsi netgen ngspice xyce klayout;
              inherit (pkgs'.python3.pkgs) 
                gdsfactory gLayout;
            };
          }
        )
        (
          nix-eda.composePythonOverlay (pkgs': pkgs: pypkgs': pypkgs: let
            callPythonPackage = lib.callPackageWith (pkgs' // pkgs'.python3.pkgs);
          in {
            mdformat = pypkgs.mdformat.overridePythonAttrs (old: {
              patches = [
                ./nix/patches/mdformat/donns_tweaks.patch
              ];
              doCheck = false;
            });
            sphinx-tippy = callPythonPackage ./nix/sphinx-tippy.nix {};
            sphinx-subfigure = callPythonPackage ./nix/sphinx-subfigure.nix {};
            yamlcore = callPythonPackage ./nix/yamlcore.nix {};
            gdsfactory = callPythonPackage ./nix/gdsfactory.nix {};
            pygmid = callPythonPackage ./nix/pygmid.nix {};
            gLayout = callPythonPackage ./nix/gLayout.nix {
              inherit (nix-eda.legacyPackages.${pkgs.system}) 
                klayout;
              inherit (pkgs'.python3.pkgs) gdsfactory;
            };

            # ---
            librelane = callPythonPackage ./default.nix {
              flake = self;
            };
          })
        )
        (pkgs': pkgs: let
          callPackage = lib.callPackageWith pkgs';
        in
          {}
          // lib.optionalAttrs pkgs.stdenv.isLinux {
            librelane-docker = callPackage ./nix/docker.nix {
              createDockerImage = nix-eda.createDockerImage;
              librelane = pkgs'.python3.pkgs.librelane;
            };
          })
      ];
    };

    # Helper functions
    createOpenLaneShell = import ./nix/create-shell.nix;

    # Packages
    legacyPackages = nix-eda.forAllSystems (
      system:
        import nix-eda.inputs.nixpkgs {
          inherit system;
          overlays = [devshell.overlays.default nix-eda.overlays.default self.overlays.default];
        }
    );

    packages = nix-eda.forAllSystems (
      system: let
        pkgs = (self.legacyPackages."${system}");
        in {
          inherit (pkgs) colab-env opensta openroad-abc openroad openfasoc;
          inherit (pkgs.python3.pkgs) librelane;
          default = pkgs.python3.pkgs.librelane;
        }
        // lib.optionalAttrs pkgs.stdenv.isLinux {
          inherit (pkgs) librelane-docker;
        }
    );

    # devshells

    devShells = nix-eda.forAllSystems (
      system: let
        pkgs = self.legacyPackages."${system}";
        callPackage = lib.callPackageWith pkgs;
      in {
        # These devShells are rather unorthodox for Nix devShells in that they
        # include the package itself. For a proper devShell, try .#dev.
        default =
          callPackage (self.createOpenLaneShell {
            extra-packages = with nix-eda.legacyPackages.${system}; [
              xschem
              xyce
            ];
          }) {};
        notebook = callPackage (self.createOpenLaneShell {
          extra-packages = with pkgs; [
            jupyter
          ];
        }) {};
        # Normal devShells
        dev = callPackage (self.createOpenLaneShell {
          extra-packages = [
            pkgs.jdupes
	    pkgs.alejandra
	    pkgs.openfasoc
	    nix-eda.legacyPackages.${system}.xschem
	    nix-eda.legacyPackages.${system}.ngspice
	    nix-eda.legacyPackages.${system}.xyce
          ];
          extra-python-packages = with pkgs.python3.pkgs; [
            pyfakefs
            pytest
            pytest-xdist
            pytest-cov
            pillow
            mdformat
            black
            ipython
            tokenize-rt
            flake8
            mypy
            types-deprecated
            types-pyyaml
            types-psutil
            lxml-stubs
            # for jupyter version control
            jupyterlab
            nbdime
          ] ++ (pkgs.openfasoc.python-packages pkgs.python3.pkgs);

          include-librelane = false;
          # used to set the PDK_ROOT
	}) {};
        docs = callPackage (self.createOpenLaneShell {
          extra-packages = with pkgs; [
            jdupes
            alejandra
            imagemagick
            nodejs.pkgs.nodemon
          ];
          extra-python-packages = with pkgs.python3.pkgs; [
            pyfakefs
            pytest
            pytest-xdist
            pillow
            mdformat
            furo
            docutils
            sphinx
            sphinx-autobuild
            sphinx-autodoc-typehints
            sphinx-design
            myst-parser
            docstring-parser
            sphinx-copybutton
            sphinxcontrib-spelling
            sphinxcontrib-bibtex
            sphinx-tippy
            sphinx-subfigure
          ];
          include-librelane = false;
        }) {};
      }
    );
  };
}
