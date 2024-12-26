{ self, inputs, ... }:
{
  flake = {
    templates.comfyui = {
      path = ./template;
      description = "Comfyui non-nixos template. Non-nixos is not officially supported, but acts as good documentation";
    };
    overlays.comfyui = (self: super: {
      comfyuiPackages = self.lib.packagesFromDirectoryRecursive {
        inherit (self) callPackage;
        directory = ./pkgs;
      };
      comfyui = self.comfyuiPackages.comfyui;
    });
    nixosModules.comfyui = { ... }: let
      overlays = [
        self.overlays.comfyui
        self.overlays.models
        self.overlays.fetchers
      ];
    in {
      imports = [ (import ./module.nix { inherit overlays; }) ];
      nixpkgs.overlays = overlays;
    };
  };
  perSystem = { config, pkgs, nvidiaPkgs, rocmPkgs, system, ... }: {
    checks.comfyui = pkgs.callPackage ./vm-test { nixosModule = inputs.self.nixosModules.comfyui; };
    packages = {
      comfyui-nvidia = nvidiaPkgs.comfyuiPackages.comfyui;
      # ROCm support in nixpkgs is pretty bad right now
      # comfyui-amd = rocmPkgs.comfyuiPackages.comfyui;
    };
  };
}
