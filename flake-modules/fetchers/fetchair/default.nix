# AIR spec: https://github.com/civitai/civitai/wiki/AIR-%E2%80%90-Uniform-Resource-Names-for-AI
{...}: {
  perSystem = {
    pkgs,
    lib,
    system,
    ...
  }: let
    constants = import ./constants.nix {inherit lib;};
    parseAIR = import ./parser.nix {
      inherit lib;
      inherit (constants) modelTypes ecosystems;
    };
    fetchair = import ./fetcher.nix {
      inherit lib parseAIR;
      fetchurl = args:
        if builtins.hasAttr "curlOptsList" args
        then pkgs.fetchurl args
        else import <nix/fetchurl.nix> args;
    };
  in {
    legacyPackages = {
      air = {inherit parseAIR fetchair;} // constants;
    };
  };
}
