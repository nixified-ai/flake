{ config, inputs, lib, withSystem, ... }:

let
  l = lib // config.flake.lib;
  inherit (config.flake) overlays;
in

{
  perSystem = { config, pkgs, ... }: let
    commonOverlays = [
      overlays.python-fixPackages
      (l.overlays.callManyPackages [
        ../../packages/accelerate
        ../../packages/analytics-python
        ../../packages/apispec-webframeworks
        ../../packages/autogptq
        # https://github.com/huggingface/datasets/issues/6352#issuecomment-1781073234
        ../../packages/datasets
        ../../packages/ffmpy
        ../../packages/flexgen
        ../../packages/gradio
        ../../packages/gradio-client
        ../../packages/llama-cpp-python
        ../../packages/peft
        ../../packages/rouge
        ../../packages/rwkv
        ../../packages/sentence-transformers
        ../../packages/speechrecognition
        ../../packages/tokenizers
        ../../packages/torch-grammar
      ])
    ];

    python3Variants = {
      amd = l.overlays.applyOverlays pkgs.python310Packages (commonOverlays ++ [
        overlays.python-torchRocm
      ]);
      nvidia = l.overlays.applyOverlays pkgs.python310Packages (commonOverlays ++ [
        overlays.python-torchCuda
        overlays.python-bitsAndBytesOldGpu
      ]);
    };

    src = inputs.textgen-src;

    mkTextGenVariant = args: pkgs.callPackage ./package.nix ({ inherit src; } // args);
  in {
    packages = {
      textgen-nvidia = mkTextGenVariant {
        python3Packages = python3Variants.nvidia;
      };
    };
    legacyPackages = {
      textgen-amd = throw ''


        text-generation-webui is not supported on AMD yet, as bitsandbytes does not support ROCm.
      '';
    };
  };

  flake.nixosModules = let
    packageModule = pkgAttrName: { pkgs, ... }: {
      services.textgen.package = withSystem pkgs.system (
        { config, ... }: lib.mkOptionDefault config.packages.${pkgAttrName}
      );
    };
  in {
    textgen = ./nixos;
    textgen-amd = {
      imports = [
        config.flake.nixosModules.textgen
        (packageModule "textgen-amd")
      ];
    };
    textgen-nvidia = {
      imports = [
        config.flake.nixosModules.textgen
        (packageModule "textgen-nvidia")
      ];
    };
  };
}

