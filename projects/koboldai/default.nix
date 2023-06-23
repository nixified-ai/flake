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
      ])
    ];

    python3Variants = {
      amd = l.overlays.applyPackageOverrides pkgs.python3 (commonOverlays ++ [
        overlays.python-torchRocm
      ]);
      nvidia = l.overlays.applyPackageOverrides pkgs.python3 (commonOverlays ++ [
        overlays.python-torchCuda
      ]);
    };

    src = inputs.koboldai-src;

    mkKoboldAIVariant = args: pkgs.callPackage ./package.nix ({ inherit src; } // args);
  in {
    packages = {
      koboldai-nvidia = mkKoboldAIVariant {
        python3Packages = python3Variants.nvidia.pkgs;
      };
      koboldai-amd = mkKoboldAIVariant {
        python3Packages = python3Variants.amd.pkgs;
      };
    };
  };

  flake.nixosModules = let
    packageModule = pkgAttrName: { pkgs, ... }: {
      services.koboldai.package = withSystem pkgs.system (
        { config, ... }: lib.mkOptionDefault config.packages.${pkgAttrName}
      );
    };
  in {
    koboldai = ./nixos;
    koboldai-amd = {
      imports = [
        config.flake.nixosModules.koboldai
        (packageModule "koboldai-amd")
      ];
    };
    koboldai-nvidia = {
      imports = [
        config.flake.nixosModules.koboldai
        (packageModule "koboldai-nvidia")
      ];
    };
  };
}
