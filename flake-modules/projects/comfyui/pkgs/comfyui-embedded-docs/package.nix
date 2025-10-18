{
  python3Packages,
  comfyuiNpins,
}:
let
  npin = comfyuiNpins.comfyui-embedded-docs;
in
python3Packages.callPackage (
  {
    lib,
    buildPythonPackage,
    fetchurl,
    setuptools,
  }:
  buildPythonPackage rec {
    pname = "comfyui_embedded_docs";

    inherit (npin) version;
    src = fetchurl {
      inherit (npin) url;
      sha256 = npin.hash;
    };

    pyproject = true;
    build-system = [
      setuptools
    ];

    pythonImportsCheck = [
      pname
    ];

    meta = {
      description = "Embedded documentation for ComfyUI nodes";
      homepage = "https://pypi.org/project/comfyui-embedded-docs/";
      license = lib.licenses.gpl3Only;
    };
  }
) { }
