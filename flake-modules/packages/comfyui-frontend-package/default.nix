# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ buildPythonPackage, fetchurl }:

buildPythonPackage {
  pname = "comfyui-frontend-package";
  version = "1.27.1";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/ed/e2/acb43aba65835989d9d62dca547f548f55e9ee7f3b514f901e288a5431a2/comfyui_frontend_package-1.27.1.tar.gz";
    sha256 = "sha256-ZygPjBJdUzhRR8qyD4JVUk0OzU+wxVXQTVS6QHUjfmM=";
  };

  format = "setuptools";
  doCheck = false;

  meta = {
    description = "comfyui-frontend-package";
    homepage = "https://github.com/Comfy-Org/ComfyUI_frontend";
  };
}
