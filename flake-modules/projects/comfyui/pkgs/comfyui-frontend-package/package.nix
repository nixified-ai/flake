{
  python3Packages,
  comfyuiNpins,
}:
let
  npin = comfyuiNpins.comfyui-frontend-package;
in
python3Packages.callPackage (
  {
    buildPythonPackage,
    fetchurl,
  }:
  buildPythonPackage rec {
    pname = "comfyui_frontend_package";

    inherit (npin) version;
    src = fetchurl {
      inherit (npin) url;
      sha256 = npin.hash;
    };

    format = "setuptools";
    pythonImportsCheck = [
      pname
    ];

    meta = {
      description = "comfyui-frontend-package";
      homepage = "https://github.com/Comfy-Org/ComfyUI_frontend";
    };
  }
) { }
