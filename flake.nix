{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        flake-parts.flakeModules.easyOverlay
      ];
  #    flake = {
  #    };
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      perSystem = { config, pkgs, system, ... }: {
        _module.args.pkgs = import inputs.nixpkgs { overlays = [ inputs.self.overlays.default ]; inherit system; };
        overlayAttrs = config.legacyPackages;
        legacyPackages = {
          makeDarwinImage = pkgs.callPackage ./makeDarwinImage {};
          makeMsDos622Image = pkgs.callPackage ./makeMsDos622Image {};
          makeWin30Image = pkgs.callPackage ./makeWin30Image {};
          makeWfwg311Image = pkgs.callPackage ./makeWfwg311Image {};
        };
        packages = rec {
          macOS-ventura-image = config.legacyPackages.makeDarwinImage {};
          msDos622-image = config.legacyPackages.makeMsDos622Image {};
          win30-image = config.legacyPackages.makeWin30Image {};
          wfwg311-image = config.legacyPackages.makeWfwg311Image {};
          everything = pkgs.symlinkJoin {
            name = "everything";
            paths = [
              macOS-ventura-image
              msDos622-image
              win30-image
              wfwg311-image
            ];
          };
        };
      };
    };
}
