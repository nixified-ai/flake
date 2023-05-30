{ ... }:
{
  perSystem = { config, ...}: {
    legacyPackages.pkgs = config.dependencySets;
  };
}
