{
  perSystem = { pkgs, ... }: {
    packages = {
      website = pkgs.callPackage ./package.nix { };
    };
  };
}
