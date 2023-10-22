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
        ../../packages/apispec-webframeworks
        ../../packages/torch-grammar
        ../../packages/flexgen
        ../../packages/gradio
        ../../packages/gradio-client
        ../../packages/analytics-python
        ../../packages/ffmpy
        ../../packages/llama-cpp-python
        ../../packages/rwkv
        ../../packages/autogptq
        ../../packages/rouge
      ])
    ];

    python3Variants = {
      amd = l.overlays.applyOverlays pkgs.python3Packages (commonOverlays ++ [
        overlays.python-torchRocm
      ]);
      nvidia = l.overlays.applyOverlays pkgs.python3Packages (commonOverlays ++ [
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

