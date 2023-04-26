{ config, inputs, lib, withSystem, ... }:

{
  perSystem = { config, pkgs, ... }:
    let
      inherit (config.dependencySets) aipython3-amd aipython3-nvidia;

      src = inputs.textgen-src;

      mkTextGenVariant = args: pkgs.callPackage ./package.nix ({ inherit src; } // args);
    in
    {
      packages = {
        textgen-nvidia = mkTextGenVariant {
          aipython3 = aipython3-nvidia;
        };
        textgen-amd = mkTextGenVariant {
          aipython3 = aipython3-amd;
        };
      };
    };

  flake.nixosModules =
    let
      packageModule = pkgAttrName: { pkgs, ... }: {
        services.textgen.package = withSystem pkgs.system (
          { config, ... }: lib.mkOptionDefault config.packages.${pkgAttrName}
        );
      };
    in
    {
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
