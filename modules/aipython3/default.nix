{ lib, ... }:

{
  perSystem = { pkgs, ... }: {
    dependencySets =
      let
        overlays = import ./overlays.nix pkgs;

        mkPythonPackages = overlayList:
          let
            python3' = pkgs.python3.override {
              packageOverrides = lib.composeManyExtensions overlayList;
            };
          in
          python3'.pkgs;

      in
      {
        aipython3-amd = mkPythonPackages [
          overlays.fixPackages
          overlays.extraDeps
          overlays.torchRocm
        ];

        aipython3-nvidia = mkPythonPackages [
          overlays.fixPackages
          overlays.extraDeps
          overlays.torchCuda
        ];
      };
  };
}
