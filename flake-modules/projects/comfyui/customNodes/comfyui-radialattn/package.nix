{
  python3Packages,
  config,
  lib,
  cudaSupport ? config.cudaSupport,
}:
finalAttrs: previousAttrs: {
  propagatedBuildInputs = lib.optionals cudaSupport [
    python3Packages.spas_sage_attn
  ];

  dontBuild = true;
  dontConfigure = true;
}
