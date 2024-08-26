# AIR spec: https://github.com/civitai/civitai/wiki/AIR-%E2%80%90-Uniform-Resource-Names-for-AI
{...}: {
  perSystem = {
    pkgs,
    lib,
    system,
    ...
  }: let
    parseAIR = import ./parser.nix {inherit lib;};
  in {
    legacyPackages = {
      air =
        {
          fetchair = import ./fetcher.nix {
            inherit lib parseAIR;
            fetchurl = args:
              if builtins.hasAttr "curlOptsList" args
              then pkgs.fetchurl args
              else import <nix/fetchurl.nix> args;
          };
          inherit parseAIR;
        }
        // import ./constants.nix {inherit lib;};
    };
  };
}
