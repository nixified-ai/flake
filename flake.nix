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
          macOs32 = pkgs.symlinkJoin {
            name = "everything";
            paths = [
              macOS-ventura-image.overrideAttrs { name = "macos1"; }
              macOS-ventura-image.overrideAttrs { name = "macos2"; }
              macOS-ventura-image.overrideAttrs { name = "macos3"; }
              macOS-ventura-image.overrideAttrs { name = "macos4"; }
              macOS-ventura-image.overrideAttrs { name = "macos5"; }
              macOS-ventura-image.overrideAttrs { name = "macos6"; }
              macOS-ventura-image.overrideAttrs { name = "macos7"; }
              macOS-ventura-image.overrideAttrs { name = "macos8"; }
              macOS-ventura-image.overrideAttrs { name = "macos9"; }
              macOS-ventura-image.overrideAttrs { name = "macos10"; }
              macOS-ventura-image.overrideAttrs { name = "macos11"; }
              macOS-ventura-image.overrideAttrs { name = "macos12"; }
              macOS-ventura-image.overrideAttrs { name = "macos13"; }
              macOS-ventura-image.overrideAttrs { name = "macos14"; }
              macOS-ventura-image.overrideAttrs { name = "macos15"; }
              macOS-ventura-image.overrideAttrs { name = "macos16"; }
              macOS-ventura-image.overrideAttrs { name = "macos17"; }
              macOS-ventura-image.overrideAttrs { name = "macos18"; }
              macOS-ventura-image.overrideAttrs { name = "macos19"; }
              macOS-ventura-image.overrideAttrs { name = "macos20"; }
              macOS-ventura-image.overrideAttrs { name = "macos21"; }
              macOS-ventura-image.overrideAttrs { name = "macos22"; }
              macOS-ventura-image.overrideAttrs { name = "macos23"; }
              macOS-ventura-image.overrideAttrs { name = "macos24"; }
              macOS-ventura-image.overrideAttrs { name = "macos25"; }
              macOS-ventura-image.overrideAttrs { name = "macos26"; }
              macOS-ventura-image.overrideAttrs { name = "macos27"; }
              macOS-ventura-image.overrideAttrs { name = "macos28"; }
              macOS-ventura-image.overrideAttrs { name = "macos29"; }
              macOS-ventura-image.overrideAttrs { name = "macos30"; }
              macOS-ventura-image.overrideAttrs { name = "macos31"; }
              macOS-ventura-image.overrideAttrs { name = "macos32"; }
            ];
          };
        };
      };
    };
}
