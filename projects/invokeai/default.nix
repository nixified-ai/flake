{ config, inputs, lib, withSystem, self,... }:

{
  perSystem = { config, pkgs, ... }: let
    inherit (config.dependencySets) aipython3-amd aipython3-nvidia;

    src = inputs.invokeai-src;

    mkInvokeAIVariant = args: pkgs.callPackage ./package.nix ({ inherit src; } // args);

    dream2nix-setup-module = {config, lib, ...}: {
      lock.repoRoot = self;
      lock.lockFileRel = "/projects/invokeai/lock-${config.deps.stdenv.system}.json";
    };

    _callModule = module:
    lib.evalModules {
      specialArgs.dream2nix = inputs.dream2nix;
      specialArgs.packageSets.nixpkgs = pkgs;
      specialArgs.inputs = {inherit (inputs) invokeai-src;};
      modules = [
        module
        dream2nix-setup-module
      ];
    };

  # like callPackage for modules
  callModule = module: (_callModule module).config.public;

  in {
    packages = {
      invokeai-amd = mkInvokeAIVariant {
        aipython3 = aipython3-amd;
      };
      invokeai-nvidia = mkInvokeAIVariant {
        aipython3 = aipython3-nvidia;
      };
      invokeai-d2n = callModule ./package-d2n.nix;
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
