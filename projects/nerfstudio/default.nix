{ config, inputs, lib, withSystem, ... }:
{
  perSystem = { config, pkgs, ... }: let
    inherit (config.dependencySets) aipython3-amd aipython3-nvidia;

    src = inputs.nerfstudio-src;

    mkNerfstudioVariant = args: pkgs.callPackage ./package.nix ({ inherit src; } // args);
  in {
    packages = {
      nerfstudio-amd = mkNerfstudioVariant {
        aipython3 = aipython3-amd;
      };
      nerfstudio-nvidia = mkNerfstudioVariant {
        aipython3 = aipython3-nvidia;
      };
    };
  };

  flake.nixosModules = let
    packageModule = pkgAttrName: { pkgs, ... }: {
      services.nerfstudio.package = withSystem pkgs.system (
        { config, ... }: lib.mkOptionDefault config.packages.${pkgAttrName}
      );
    };
  in {
    invokeai = ./nixos;
    invokeai-amd = {
      imports = [
        config.flake.nixosModules.nerfstudio
        (packageModule "nerfstudio-amd")
      ];
    };
    invokeai-nvidia = {
      imports = [
        config.flake.nixosModules.nerfstudio
        (packageModule "nerfstudio-nvidia")
      ];
    };
  };
}
