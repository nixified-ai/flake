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

  in {
    packages = {
      invokeai-amd = mkInvokeAIVariant {
        aipython3 = aipython3-amd;
      };
      invokeai-nvidia = mkInvokeAIVariant {
        aipython3 = aipython3-nvidia;
      };
      invokeai-d2n = inputs.dream2nix.lib.evalModules {
        modules = [
          dream2nix-setup-module
          ./package-d2n.nix
        ];
        packageSets.nixpkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
        specialArgs.inputs = {inherit (inputs) invokeai-src;};
      };
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
