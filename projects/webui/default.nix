{ inputs, lib, ... }:

{
  perSystem = { config, pkgs, ... }: let
    inherit (config.dependencySets) aipython3-amd aipython3-nvidia;

    src = inputs.webui-src;
  in {
    packages = {
      webui-amd = aipython3-amd.callPackage ./package.nix {
        inherit src;
      };
      webui-nvidia = aipython3-nvidia.callPackage ./package.nix {
        inherit src;
      };
    };
  };
}
