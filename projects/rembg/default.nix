{ config, inputs, lib, withSystem, ... }:

{
  perSystem = { config, pkgs, ... }:
    let
      inherit (config.dependencySets) aipython3-cpu;

      src = inputs.rembg-src;

      mkInvokeAIVariant = args: pkgs.callPackage ./package.nix ({ inherit src; } // args);
    in
    {
      packages = {
        rembg-cpu = mkInvokeAIVariant {
          aipython3 = aipython3-cpu;
        };
      };
    };

  flake.nixosModules =
    let
      packageModule = pkgAttrName: { pkgs, ... }: {
        services.rembg.package = withSystem pkgs.system (
          { config, ... }: lib.mkOptionDefault config.packages.${pkgAttrName}
        );
      };
    in
    {
      rembg = ./nixos;
      rembg-cpu = {
        imports = [
          config.flake.nixosModules.rembg
          (packageModule "rembg-cpu")
        ];
      };
    };
}
