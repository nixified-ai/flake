{ config, inputs, lib, ... }:

let
  l = lib // config.flake.lib;
  inherit (config.flake) overlays;

  commonOverlays = [
    overlays.python-fixPackages
    (l.overlays.callManyPackages [
      ../../packages/safetensors
      ../../packages/accelerate
      ../../packages/pytorch-lightning
    ])
  ];

  variantOverlays = {
    amd = [ overlays.python-torchRocm ];
    nvidia = [ overlays.python-torchCuda ];
  };

  mkVariant =
    pkgs: name:
    pkgs.callPackage ./package.nix {
      src = inputs.fooocus-src;
      python3Packages =
        l.overlays.applyOverlays pkgs.python3Packages
          (commonOverlays ++ variantOverlays.${name});
    };

in {
  perSystem =
    { config, pkgs, ... }:
    {
      packages = {
        fooocus-amd = mkVariant pkgs "amd";
        fooocus-nvidia = mkVariant pkgs "nvidia";
      };
    };
}
