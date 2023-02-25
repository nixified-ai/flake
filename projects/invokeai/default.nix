{ inputs, lib, ... }:

{
  perSystem = { config, pkgs, ... }: let
    inherit (config.dependencySets) aipython3-amd aipython3-nvidia;

    src = inputs.invokeai-src;

    mkInvokeAIVariant = args: pkgs.callPackage ./package.nix ({ inherit src; } // args);
  in {
    packages = {
      invokeai-amd = mkInvokeAIVariant {
        aipython3 = aipython3-amd;
      };
      invokeai-nvidia = mkInvokeAIVariant {
        aipython3 = aipython3-nvidia;
      };
    };
  };
}
