{ inputs, lib, ... }:

{
  perSystem = { system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
          "torch"
          "triton"
          "cuda_nvtx"
          "cuda_cudart"
        ];
      };
    };
  };
}