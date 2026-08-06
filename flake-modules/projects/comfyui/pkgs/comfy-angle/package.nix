{
  python3Packages,
  fetchurl,
  lib,
  stdenv,
  autoPatchelfHook,
  xorg,
}:
python3Packages.buildPythonPackage rec {
  pname = "comfy-angle";
  version = "0.1.0";
  format = "wheel";

  src =
    let
      system = stdenv.hostPlatform.system;
      wheelInfo = {
        x86_64-linux = {
          url = "https://files.pythonhosted.org/packages/94/79/09033953c3f2ef3d31e7cd626e01db9cdd2760a50bb22b83fa6aef32561e/comfy_angle-0.1.0-py3-none-manylinux_2_28_x86_64.whl";
          hash = "sha256-L00X6YQ1PTfSR/r0c6+6vbmGP8OvPgIG+7fYK9wjrGc=";
        };
        aarch64-linux = {
          url = "https://files.pythonhosted.org/packages/65/1d/87298bb1935268c63bc27d24487b5e40f58e74da3138e122123ce6b052cb/comfy_angle-0.1.0-py3-none-manylinux_2_28_aarch64.whl";
          hash = "sha256-RFRp23i1y5W1jZ4HwAIFkK29yQ1MkVr5lD5v73eY9iY=";
        };
      };
    in
    fetchurl wheelInfo.${system};

  # Make it dynamically linked with patchelf
  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = with xorg; [
    libX11
    libXext
    libxcb
  ];
}
