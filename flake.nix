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
          macOS-30 = pkgs.linkFarm [
            { name = "macos1"; path = macOS-ventura-image.overrideAttrs { name = "macos1"; }; }
            { name = "macos2"; path = macOS-ventura-image.overrideAttrs { name = "macos2"; }; }
            { name = "macos3"; path = macOS-ventura-image.overrideAttrs { name = "macos3"; }; }
            { name = "macos4"; path = macOS-ventura-image.overrideAttrs { name = "macos4"; }; }
            { name = "macos5"; path = macOS-ventura-image.overrideAttrs { name = "macos5"; }; }
            { name = "macos6"; path = macOS-ventura-image.overrideAttrs { name = "macos6"; }; }
            { name = "macos7"; path = macOS-ventura-image.overrideAttrs { name = "macos7"; }; }
            { name = "macos8"; path = macOS-ventura-image.overrideAttrs { name = "macos8"; }; }
            { name = "macos9"; path = macOS-ventura-image.overrideAttrs { name = "macos9"; }; }
            { name = "macos10"; path = macOS-ventura-image.overrideAttrs { name = "macos10"; }; }
            { name = "macos11"; path = macOS-ventura-image.overrideAttrs { name = "macos11"; }; }
            { name = "macos12"; path = macOS-ventura-image.overrideAttrs { name = "macos12"; }; }
            { name = "macos13"; path = macOS-ventura-image.overrideAttrs { name = "macos13"; }; }
            { name = "macos14"; path = macOS-ventura-image.overrideAttrs { name = "macos14"; }; }
            { name = "macos15"; path = macOS-ventura-image.overrideAttrs { name = "macos15"; }; }
            { name = "macos16"; path = macOS-ventura-image.overrideAttrs { name = "macos16"; }; }
            { name = "macos17"; path = macOS-ventura-image.overrideAttrs { name = "macos17"; }; }
            { name = "macos18"; path = macOS-ventura-image.overrideAttrs { name = "macos18"; }; }
            { name = "macos19"; path = macOS-ventura-image.overrideAttrs { name = "macos19"; }; }
            { name = "macos20"; path = macOS-ventura-image.overrideAttrs { name = "macos20"; }; }
            { name = "macos21"; path = macOS-ventura-image.overrideAttrs { name = "macos21"; }; }
            { name = "macos22"; path = macOS-ventura-image.overrideAttrs { name = "macos22"; }; }
            { name = "macos23"; path = macOS-ventura-image.overrideAttrs { name = "macos23"; }; }
            { name = "macos24"; path = macOS-ventura-image.overrideAttrs { name = "macos24"; }; }
            { name = "macos25"; path = macOS-ventura-image.overrideAttrs { name = "macos25"; }; }
            { name = "macos26"; path = macOS-ventura-image.overrideAttrs { name = "macos26"; }; }
            { name = "macos27"; path = macOS-ventura-image.overrideAttrs { name = "macos27"; }; }
            { name = "macos28"; path = macOS-ventura-image.overrideAttrs { name = "macos28"; }; }
            { name = "macos29"; path = macOS-ventura-image.overrideAttrs { name = "macos29"; }; }
            { name = "macos30"; path = macOS-ventura-image.overrideAttrs { name = "macos30"; }; }
          ];
        };
      };
    };
}
