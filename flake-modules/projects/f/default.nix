{ self, inputs, ... }:
{
  perSystem = { config, pkgs, nvidiaPkgs, rocmPkgs, system, ... }: {
    packages = rec {
      ai-toolkit = nvidiaPkgs.callPackage ./package.nix {};
    };
  };
}
