{ lib
, buildPythonPackage
, fetchPypi
, setuptools
,
}:

buildPythonPackage rec {
  pname = "comfyui-embedded-docs";
  version = "0.2.0";
  pyproject = true;

  src = fetchPypi {
    pname = "comfyui_embedded_docs";
    inherit version;
    hash = "sha256-z5OSbWkDO8KZPFzCG4HmrY55VTrFPu9+Yz8Xixtcj9k=";
  };

  build-system = [
    setuptools
  ];

  pythonImportsCheck = [
    "comfyui_embedded_docs"
  ];

  meta = {
    description = "Embedded documentation for ComfyUI nodes";
    homepage = "https://pypi.org/project/comfyui-embedded-docs/";
    license = lib.licenses.gpl3Only;
  };
}
