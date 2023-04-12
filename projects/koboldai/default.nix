{ config, inputs, lib, withSystem, ... }:

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
