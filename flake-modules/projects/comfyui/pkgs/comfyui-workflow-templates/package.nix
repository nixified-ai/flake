{
  python3Packages,
  comfyuiNpins,
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
      python3Packages.comfyui-workflow-templates-core
    ];

    pythonImportsCheck = [
      pname
    ];

    meta = with lib; {
      description = "ComfyUI workflow templates available via the Browse Templates feature.";
      homepage = "https://github.com/Comfy-Org/workflow_templates";
      license = licenses.gpl3;
      maintainers = [ ];
      platforms = platforms.all;
    };
  }
) { }
