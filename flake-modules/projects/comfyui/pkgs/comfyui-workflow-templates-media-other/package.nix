{
  python3Packages,
  comfyuiNpins,
}:
let
  npin = comfyuiNpins.comfyui-workflow-templates-media-other;
in
python3Packages.callPackage (
  {
    lib,
    buildPythonPackage,
    fetchurl,
  }:
  buildPythonPackage rec {
    pname = "comfyui_workflow_templates_media_other";

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
      description = "Media-Other module for ComfyUI workflow templates.";
      homepage = "nix";
      license = licenses.gpl3;
    };
  }
) { }
