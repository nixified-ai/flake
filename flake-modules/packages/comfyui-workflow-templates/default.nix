{ lib
, buildPythonPackage
, fetchPypi
, setuptools
,
}:

buildPythonPackage rec {
  pname = "comfyui-workflow-templates";
  version = "0.1.3";
  pyproject = true;

  src = fetchPypi {
    pname = "comfyui_workflow_templates";
    inherit version;
    hash = "sha256-Ivnf+xOOGzMJpu68RFH37vFPEsT9g/KxWUlMiE+Hglk=";
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
