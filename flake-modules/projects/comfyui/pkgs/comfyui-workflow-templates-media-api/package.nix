{
  python3Packages,
  comfyuiNpins,
}:
let
  npin = comfyuiNpins.comfyui-workflow-templates-media-api;
in
python3Packages.callPackage (
  {
    lib,
    buildPythonPackage,
    fetchurl,
  }:
  buildPythonPackage rec {
    pname = "comfyui_workflow_templates_media_api";

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
      description = "Media-Api module for ComfyUI workflow templates.";
      homepage = "nix";
      license = licenses.gpl3;
    };
  }
) { }
