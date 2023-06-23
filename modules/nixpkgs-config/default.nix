{ inputs, lib, ... }:

{
  perSystem = { system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
          # TODO: classify
          "torch"
          "triton"
          "cuda_nvtx"
          "cuda_cudart"

          # for ROCm?
          "libcublas"
          "libcusparse"
          "cuda_nvcc"
          "cuda_nvprof"
          "cuda_cupti"
        ];
      };
    };
  };
}