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
        ../../packages/safetensors
        ../../packages/compel
        ../../packages/taming-transformers-rom1504
        ../../packages/albumentations
        ../../packages/qudida
        ../../packages/gfpgan
        ../../packages/basicsr
        ../../packages/facexlib
        ../../packages/realesrgan
        ../../packages/codeformer
        ../../packages/clipseg
        ../../packages/kornia
        ../../packages/picklescan
        ../../packages/diffusers
        ../../packages/pypatchmatch
        ../../packages/torch-fidelity
        ../../packages/resize-right
        ../../packages/torchdiffeq
        ../../packages/k-diffusion
        ../../packages/accelerate
        ../../packages/clip-anytorch
        ../../packages/clean-fid
        ../../packages/getpass-asterisk
      ])
      (final: prev: lib.mapAttrs
        (_: pkg: pkg.overrideAttrs (old: {
          nativeBuildInputs = old.nativeBuildInputs ++ [ final.pythonRelaxDepsHook ];
          pythonRemoveDeps = [ "opencv-python-headless" "opencv-python" "tb-nightly" "clip" ];
        }))
        {
          inherit (prev)
            albumentations
            qudida
            gfpgan
            basicsr
            facexlib
            realesrgan
            clipseg
          ;
        }
      )
    ];

    python3Variants = {
      amd = l.overlays.applyPackageOverrides pkgs.python3 (commonOverlays ++ [
        overlays.python-torchRocm
      ]);
      nvidia = l.overlays.applyPackageOverrides pkgs.python3 (commonOverlays ++ [
        overlays.python-torchCuda
      ]);
    };

    src = inputs.invokeai-src;

    mkInvokeAIVariant = args: pkgs.callPackage ./package.nix ({ inherit src; } // args);
  in {
    packages = {
      invokeai-amd = mkInvokeAIVariant {
        python3Packages = python3Variants.amd.pkgs;
      };
      invokeai-nvidia = mkInvokeAIVariant {
        python3Packages = python3Variants.nvidia.pkgs;
      };
    };
  };

  flake.nixosModules = let
    packageModule = pkgAttrName: { pkgs, ... }: {
      services.invokeai.package = withSystem pkgs.system (
        { config, ... }: lib.mkOptionDefault config.packages.${pkgAttrName}
      );
    };
  in {
    invokeai = ./nixos;
    invokeai-amd = {
      imports = [
        config.flake.nixosModules.invokeai
        (packageModule "invokeai-amd")
      ];
    };
    invokeai-nvidia = {
      imports = [
        config.flake.nixosModules.invokeai
        (packageModule "invokeai-nvidia")
      ];
    };
  };
}
