{ inputs, lib, ... }:

{
  perSystem = { system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
          # for Triton
          "cuda_cudart"
          "cuda_nvcc"
          "cuda_nvtx"

          # for CUDA Torch
          "cuda_cccl"
          "cuda_cupti"
          "cuda_nvprof"
          "cudatoolkit"
          "cudatoolkit-11-cudnn"
          "libcublas"
          "libcusolver"
          "libcusparse"
        ];
      };
    };
  };
}