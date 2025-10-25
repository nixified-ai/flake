{ self, inputs, ... }:
{
  flake = {
    templates.comfyui = {
      path = ./template;
      description = "Comfyui non-nixos template. Non-nixos is not officially supported, but acts as good documentation";
    };
    overlays.comfyui = (
      self: super:
      let
        inherit (self) lib comfyuiLib customCustomNodesPins;
        comfyuiCustomNodes = lib.mapAttrs (
          name: pin:
          let
            inherit (self) callPackage;
            packageBase = callPackage (
              { stdenv }: stdenv.mkDerivation (comfyuiLib.nodePropsFromNpinSource pin)
            ) { };
            overridesFile = ./customNodes/${name}/package.nix;
            packageWithOverrides =
              if lib.pathExists overridesFile then
                let
                  overridePayload =
                    lib.removeAttrs (callPackage overridesFile { })
                      # these cuses issues down the line when building the package
                      # TODO: is there a way to get callPackage style dependency
                      # injection without these being added?
                      [
                        "override"
                        "overrideDerivation"
                      ];
                in
                packageBase.overrideAttrs overridePayload
              else
                packageBase;
          in
          comfyuiLib.mkComfyUICustomNode packageWithOverrides
        ) customCustomNodesPins;
      in
      {
        customCustomNodesPins = (builtins.fromJSON (lib.readFile ./customNodes-npins/sources.json)).pins;
        comfyuiNpins = (builtins.fromJSON (lib.readFile ./npins/sources.json)).pins;
        inherit comfyuiCustomNodes;
        comfyuiLib = self.callPackage ./lib.nix { };
        comfyuiPackages =
          (self.lib.packagesFromDirectoryRecursive {
            inherit (self) callPackage;
            directory = ./pkgs;
          })
          // comfyuiCustomNodes;
        comfyui = self.comfyuiPackages.comfyui;
        python3Packages = super.python3Packages.overrideScope (
          pyfinal: pyprev:
          let
            extraPackages = self.lib.packagesFromDirectoryRecursive {
              inherit (pyfinal) callPackage;
              directory = ./../../packages;
            };
            names = lib.attrNames extraPackages;
            extraPackagesAlreadyInPrev = lib.filter (name: pyprev ? ${name}) names;
            warningMessage = "Some local python packages are already present in upstream: ${lib.concatStringsSep ", " extraPackagesAlreadyInPrev}";
            extraPackagesWithWarning = lib.warnIfNot (
              [ ] == extraPackagesAlreadyInPrev
            ) warningMessage extraPackages;
          in
          {
            # TODO: delete once merged upstream: https://github.com/NixOS/nixpkgs/pull/453306/files
            pymatting = pyprev.pymatting.overridePythonAttrs {
              disabledTestPaths = self.lib.optional self.config.cudaSupport "tests/test_foreground.py";
            };
          }
          // extraPackagesWithWarning
        );
      }
    );
    nixosModules.comfyui =
      { ... }:
      let
        overlays = [
          self.overlays.comfyui
          self.overlays.models
          self.overlays.fetchers
        ];
      in
      {
        imports = [ (import ./module.nix { inherit overlays; }) ];
        nixpkgs.overlays = overlays;
      };
  };
  perSystem =
    {
      config,
      pkgs,
      nvidiaPkgs,
      rocmPkgs,
      system,
      ...
    }:
    {
      checks.comfyui = pkgs.callPackage ./vm-test { nixosModule = inputs.self.nixosModules.comfyui; };
      packages = {
        comfyui-nvidia = nvidiaPkgs.comfyuiPackages.comfyui // {
          passthru = nvidiaPkgs.comfyuiPackages.comfyui.passthru // {
            inherit (nvidiaPkgs)
              customCustomNodesPins
              comfyuiCustomNodes
              comfyuiLib
              comfyuiPackages
              ;
          };
        };
        # ROCm support in nixpkgs is pretty bad right now
        # comfyui-amd = rocmPkgs.comfyuiPackages.comfyui;
      };
    };
}
