{ inputs, lib, ... }:

{
  perSystem = { config, pkgs, ... }: let
    inherit (config.dependencySets) aipython3-amd aipython3-nvidia;

    src = inputs.koboldai-src;

    mkKoboldAIVariant = args: pkgs.callPackage ./package.nix ({ inherit src; } // args);
  in {
    packages = {
      koboldai-nvidia = mkKoboldAIVariant {
        aipython3 = aipython3-nvidia;
      };
      koboldai-amd = mkKoboldAIVariant {
        aipython3 = aipython3-amd;
      };
    };
  };
}
