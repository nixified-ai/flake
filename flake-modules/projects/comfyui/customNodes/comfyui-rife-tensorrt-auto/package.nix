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
}
