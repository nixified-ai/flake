{
  lib,
  buildPythonPackage,
  fetchurl,
  cudaPackages,
}:

buildPythonPackage rec {
  pname = "polygraphy";
  version = "0.50.3";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/0b/a3/5c4d2413c5d659f706f4c718a5ba02ea1cad93bc5ec3aac78a7cc3ea7db5/polygraphy-0.50.3-py3-none-any.whl";
    hash = "sha256-DfGiM2235ulbXlQJTeMHaZWT8JJZetlHLXzs7/SopG4=";
  };

  doCheck = false;

  postInstall = ''
    substituteInPlace $out/lib/python3*/site-packages/polygraphy/cuda/cuda.py \
      --replace-warn 'fallback_lib = "libcudart.so"' 'fallback_lib = "${lib.getLib cudaPackages.cuda_cudart}/lib/libcudart.so"'
  '';

  meta = with lib; {
    description = "A toolkit for TensorRT, including a Python API and command-line tools";
    homepage = "https://github.com/NVIDIA/TensorRT/tree/main/tools/Polygraphy";
    license = licenses.asl20;
  };
}
