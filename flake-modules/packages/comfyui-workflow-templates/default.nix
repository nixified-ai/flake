{ lib
, buildPythonPackage
, fetchPypi
, setuptools
,
}:

buildPythonPackage rec {
  pname = "comfyui-workflow-templates";
  version = "0.1.25";
  pyproject = true;

  src = fetchPypi {
    pname = "comfyui_workflow_templates";
    inherit version;
    hash = "sha256-OE9XYdZR72bhCGP3jfjLtfrsFZf3Dfa3vTjissNT0c8=";
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
