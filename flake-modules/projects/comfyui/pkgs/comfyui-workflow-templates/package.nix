{
  python3Packages,
  comfyuiNpins,
  comfyuiPackages,
}:
let
  npin = comfyuiNpins.comfyui-workflow-templates;
in
python3Packages.callPackage (
  {
    lib,
    buildPythonPackage,
    fetchurl,
  }:
  buildPythonPackage rec {
    pname = "comfyui_workflow_templates";

    inherit (npin) version;
    src = fetchurl {
      inherit (npin) url;
      sha256 = npin.hash;
    };

    format = "setuptools";

    propagatedBuildInputs = [
      comfyuiPackages.comfyui-workflow-templates-core
    ];

    pythonImportsCheck = [
      pname
    ];

    meta = with lib; {
      description = "ComfyUI workflow templates available in the app by clicking the Workflow button then the Browse Templates button.";
      homepage = "https://github.com/Comfy-Org/workflow_templates";
      license = licenses.gpl3;
    };
  }
) { }
