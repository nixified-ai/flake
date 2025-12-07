{
  python3Packages,
  comfyuiNpins,
}:
let
  npin = comfyuiNpins.comfyui-workflow-templates-core;
in
python3Packages.callPackage (
  {
    lib,
    buildPythonPackage,
    fetchurl,
  }:
  buildPythonPackage rec {
    pname = "comfyui_workflow_templates_core";

    inherit (npin) version;
    src = fetchurl {
      inherit (npin) url;
      sha256 = npin.hash;
    };

    format = "pyproject";

    nativeBuildInputs = with python3Packages; [
      setuptools
      wheel
    ];

    pythonImportsCheck = [
      pname
    ];

    meta = with lib; {
      description = "Core module for ComfyUI workflow templates.";
      homepage = "nix";
      license = licenses.gpl3;
    };
  }
) { }
