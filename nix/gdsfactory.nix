# Copyright 2024 Efabless Corporation
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
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  setuptools_scm,
  # Tools
  klayout,
  # Python
  matplotlib,
  numpy,
  rich,
  flit-core,
  orjson,
  pandas,
  pydantic,
  pydantic-settings,
  pydantic-extra-types,
  pyyaml,
  qrcode,
  scipy,
  shapely,
  toolz,
  types-pyyaml,
  typer,
  watchdog,
  freetype-py,
  mapbox-earcut,
  networkx,
  trimesh,
  ipykernel,
  attrs,
  aenum,
  cachetools,
  gitpython,
  loguru,
  requests,
  tomli,
  cython_0,
  ruamel-yaml,
  jinja2,
  graphviz,
  flatdict,
  gdstk,
  omegaconf,
  tqdm,
}: let
  rectangle-packer = buildPythonPackage {
    pname = "rectangle-packer";
    format = "pyproject";
    version = "2.0.2";

    buildInputs = [
      setuptools
      cython_0
    ];

    src = fetchPypi {
      inherit (rectangle-packer) pname version;
      sha256 = "sha256-NORQApJV9ybEqObpOaGMrVh58Nn+WIwYeP6FyHLcvkE=";
    };
    doCheck = false;
  };

  rectpack = buildPythonPackage {
    pname = "rectpack";
    format = "pyproject";
    version = "0.2.2";

    buildInputs = [
      setuptools
    ];

    propagatedBuildInputs = [
    ];

    src = fetchPypi {
      inherit (rectpack) pname version;
      sha256 = "sha256-FeODUF/fuutV7GQKWCXZyizokBmmzdVS1uV+w2xouio=";
    };
    doCheck = false;
  };

  ruamel-yaml-string = buildPythonPackage {
    pname = "ruamel.yaml.string";
    format = "pyproject";
    version = "0.1.1";

    buildInputs = [
      setuptools
    ];

    propagatedBuildInputs = [
      ruamel-yaml
    ];

    src = fetchPypi {
      inherit (ruamel-yaml-string) pname version;
      sha256 = "sha256-enrtzAVdRcAE04t1b1hHTr77EGhR9M5WzlhBVwl4Q1A=";
    };
    doCheck = false;
  };


  trimesh = buildPythonPackage {
    pname = "trimesh";
    format = "pyproject";
    version = "4.4.1";

    buildInputs = [
      setuptools
    ];

    propagatedBuildInputs = [
      numpy
    ];

    src = fetchPypi {
      inherit (trimesh) pname version;
      sha256 = "sha256-dn/jyGa6dObZqdIWw07MHP4vvz8SmmwR1ZhxcFpZGro=";
    };
    doCheck = false;
  };

  self = buildPythonPackage {
    pname = "gdsfactory";
    format = "pyproject";
    version = "7.7.0";

    buildInputs = [
      flit-core
    ];

    propagatedBuildInputs = [
      matplotlib
      numpy
      orjson
      pandas
      pydantic
      pydantic-settings
      pydantic-extra-types
      pyyaml
      qrcode
      rectpack
      rich
      scipy
      shapely
      toolz
      types-pyyaml
      typer
      watchdog
      freetype-py
      mapbox-earcut
      networkx
      trimesh
      ipykernel
      attrs
      jinja2
      graphviz
      flatdict
      gdstk
      loguru
      omegaconf
      tqdm
    ];

    src = fetchPypi {
      inherit (self) pname version;
      sha256 = "sha256-pcD9Wrxe6tkwiOmClQSZQTsORwtEg2kPUEma30SbTYM=";
    };
    doCheck = false;

    postPatch = ''
      substituteInPlace pyproject.toml \
        --replace "\"scikit-image\"," ""
    '';

    meta = {
      description = "python library to design chips (Photonics, Analog, Quantum, MEMs, ...), objects for 3D printing or PCBs.";
      homepage = "https://gdsfactory.github.io/gdsfactory/";
      license = [lib.licenses.mit];
      platforms = lib.platforms.unix;
      mainProgram = "gf";
    };
  };
in
  self
