{ lib
, buildPythonPackage
, fetchPypi
, setuptools
,
}:

buildPythonPackage rec {
  pname = "comfyui-workflow-templates";
  version = "0.1.1";
  pyproject = true;

  src = fetchPypi {
    pname = "comfyui_workflow_templates";
    inherit version;
    hash = "sha256-CIbdF2X0jilOVM7SgaPLwN0zniqjgIm3YnN6mMVoBQo=";
  };

  build-system = [
    setuptools
  ];

  pythonImportsCheck = [
    "comfyui_workflow_templates"
  ];

  meta = {
    description = "ComfyUI workflow templates package";
    homepage = "https://pypi.org/project/comfyui-workflow-templates/";
    license = lib.licenses.gpl3Only;
  };
}
