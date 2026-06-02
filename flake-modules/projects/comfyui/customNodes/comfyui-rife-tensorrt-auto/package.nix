{
  python3Packages,
  cudatoolkit,
  config,
  lib,
  cudaSupport ? config.cudaSupport or false,
}:
finalAttrs: previousAttrs: {
  propagatedBuildInputs =
    lib.optionals cudaSupport [
      python3Packages.tensorrt
      cudatoolkit
      python3Packages.polygraphy
    ]
    ++ (with python3Packages; [
      einops
      colored
      requests
      tqdm
    ]);

  env.DISABLE_TENSORRT_AUTO_INSTALL = "true";

  postPatch = ''
    # Disable the auto-installation logic that calls pip
    substituteInPlace __init__.py \
      --replace-fail "_auto_install_tensorrt()" "pass # Disabled for Nix"
  '';
}
