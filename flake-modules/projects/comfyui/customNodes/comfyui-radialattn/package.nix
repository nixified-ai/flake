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

  postPatch = "substituteInPlace attn_mask.py \\\n  --replace-fail '        raise RuntimeError(\"Failed to import spas_sage_attn. Please install it following the instructions at https://github.com/woct0rdho/SpargeAttn\")' '        block_sparse_sage2_attn_cuda = None' \\\n  --replace-fail '    output = block_sparse_sage2_attn_cuda(' '    if block_sparse_sage2_attn_cuda is None:\n        raise RuntimeError(\"Failed to import spas_sage_attn. Please install it following the instructions at https://github.com/woct0rdho/SpargeAttn\")\n    output = block_sparse_sage2_attn_cuda('\n";

  dontBuild = true;
  dontConfigure = true;
}
