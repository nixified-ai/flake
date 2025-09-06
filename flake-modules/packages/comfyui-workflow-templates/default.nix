{ lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "comfyui_workflow_templates";

  version = "0.1.75";
  src = fetchPypi {
    inherit version pname;
    hash = "sha256-opMfmKq2KLzH9VOAAHi4nm48zTdIQbPQvzreCKOga1w=";
  };

  format = "setuptools";

  meta = with lib; {
    description = "ComfyUI workflow templates available in the app by clicking the Workflow button then the Browse Templates button.";
    homepage = "https://github.com/Comfy-Org/workflow_templates";
    license = licenses.gpl3;
    maintainers = [ ];
  };
}
