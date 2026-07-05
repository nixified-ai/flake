{ self, inputs, ... }:
{
  imports = [ ./ci.nix ];
  flake = {
    templates.comfyui = {
      path = ./template;
      description = "Comfyui non-nixos template. Non-nixos is not officially supported, but acts as good documentation";
    };
    overlays.comfyui = (
      self: super:
      let
        inherit (self) lib comfyuiLib customCustomNodesPins;
        comfyuiCustomNodes =
          (lib.mapAttrs (
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
          ) customCustomNodesPins)
          // (
            let
              localFreezeString = self.callPackage (
                { stdenv }:
                comfyuiLib.mkComfyUICustomNode (
                  stdenv.mkDerivation {
                    pname = "comfyui-freezestring";
                    version = "0.1.0";
                    src = ../../../ComfyUI-FreezeString;
                  }
                )
              ) { };
            in
            {
              comfyui-freezestring = localFreezeString;
              cofmyui-freezestring = localFreezeString.overrideAttrs (old: {
                pname = "cofmyui-freezestring";
              });
            }
          );
      in
      rec {
        COMFY_CUDA_ARCHS = "8.6";
        customCustomNodesPins = (builtins.fromJSON (lib.readFile ./customNodes-npins/sources.json)).pins;
        comfyuiNpins = (builtins.fromJSON (lib.readFile ./npins/sources.json)).pins;
        inherit comfyuiCustomNodes;

        managerCustomNodesPins =
          if lib.pathExists ./manager-npins/sources.json then
            (builtins.fromJSON (lib.readFile ./manager-npins/sources.json)).pins
          else
            { };

        managerCustomNodes = builtins.mapAttrs (
          name: source:
          let
            nodeProps = comfyuiLib.nodePropsFromNpinSource source;
            inherit (self) callPackage;
            packageBase = callPackage ({ stdenv }: stdenv.mkDerivation nodeProps) { };
            overridesFile = ./customNodes/${name}/package.nix;
            packageWithOverrides =
              if lib.pathExists overridesFile then
                let
                  overridePayload = lib.removeAttrs (callPackage overridesFile { }) [
                    "override"
                    "overrideDerivation"
                  ];
                in
                packageBase.overrideAttrs overridePayload
              else
                packageBase;
          in
          comfyuiLib.mkComfyUICustomNode packageWithOverrides
        ) managerCustomNodesPins;

        comfyuiLib = self.callPackage ./lib.nix { };
        comfyuiPackages =
          (self.lib.packagesFromDirectoryRecursive {
            inherit (self) callPackage;
            directory = ./pkgs;
          })
          // managerCustomNodes
          // comfyuiCustomNodes;
        comfyui = self.comfyuiPackages.comfyui;
        cudaPackages = super.cudaPackages.overrideScope (
          cudafinal: cudaprev: {
            tensorrt = cudafinal.callPackage ./tensorrt.nix { };
          }
        );
        python3Packages = super.python3Packages.overrideScope (
          pyfinal: pyprev:
          let
            extraPackages = self.lib.packagesFromDirectoryRecursive {
              inherit (pyfinal) callPackage;
              directory = ./../../packages;
            };
            names = lib.attrNames extraPackages;
            ignoredOverlaps = [ "llama-cpp-python" ];
            extraPackagesAlreadyInPrev = lib.filter (
              name: pyprev ? ${name} && !lib.elem name ignoredOverlaps
            ) names;
            warningMessage = "Some local python packages are already present in upstream: ${lib.concatStringsSep ", " extraPackagesAlreadyInPrev}";
            extraPackagesWithWarning = lib.warnIfNot (
              [ ] == extraPackagesAlreadyInPrev
            ) warningMessage extraPackages;
          in
          extraPackagesWithWarning
          // {
            compressed-tensors = pyprev.compressed-tensors.overridePythonAttrs (oldAttrs: {
              postPatch = (oldAttrs.postPatch or "") + ''
                sed -i '/def test_quantization_enabled_disabled():/a \    torch.manual_seed(42)' tests/test_quantization/lifecycle/test_enabled.py
              '';
            });
            transformers = pyprev.transformers.overridePythonAttrs (oldAttrs: {
              postPatch = (oldAttrs.postPatch or "") + ''
                substituteInPlace src/transformers/utils/import_utils.py \
                  --replace-warn 'PACKAGE_DISTRIBUTION_MAPPING["flash_attn"]' 'PACKAGE_DISTRIBUTION_MAPPING.get("flash_attn", [])'
              '';
            });
          }
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
      lib,
      pkgs,
      nvidiaPkgs,
      ...
    }:
    let
      scripts =
        lib.removeAttrs
          (lib.packagesFromDirectoryRecursive {
            inherit (pkgs) callPackage;
            newScope = pkgs.newScope;
            directory = ./scripts;
          })
          # Price we pay for scripts being able to depend on
          # one another. Or is there a better way?
          [
            "callPackage"
            "newScope"
            "overrideScope"
            "packages"
            "recurseForDerivations"
          ];
      enableContainerTests = inputs.enable-container-tests.value;
      container-tests = {
        comfyui-negative-test = pkgs.callPackage ./vm-test/negative-test.nix {
          nixosModule = inputs.self.nixosModules.comfyui;
        };
        comfyui-freeze-string-test = pkgs.callPackage ./vm-test/freeze-string-test.nix {
          nixosModule = inputs.self.nixosModules.comfyui;
        };
      }
      // (lib.removeAttrs
        (pkgs.callPackage ./vm-test/custom-nodes-tests.nix {
          nixosModule = inputs.self.nixosModules.comfyui;
        })
        [
          "override"
          "overrideDerivation"
          "comfyui-custom-node-comfyui-radialattn"
          "comfyui-custom-node-comfyui-rife-tensorrt-auto"
          "comfyui-custom-node-comfyui-seedvr2-videoupscaler"
        ]
      );
    in
    {
      checks = {
        comfyui = pkgs.callPackage ./vm-test { nixosModule = inputs.self.nixosModules.comfyui; };
      }
      // (lib.optionalAttrs enableContainerTests container-tests);
      packages = {
        comfyui-nvidia = nvidiaPkgs.comfyuiPackages.comfyui // {
          passthru = nvidiaPkgs.comfyuiPackages.comfyui.passthru // {
            inherit (nvidiaPkgs)
              python3Packages
              customCustomNodesPins
              comfyuiCustomNodes
              managerCustomNodesPins
              managerCustomNodes
              comfyuiLib
              comfyuiPackages
              ;
          };
        };
        # ROCm support in nixpkgs is pretty bad right now
        # comfyui-amd = rocmPkgs.comfyuiPackages.comfyui;
      };
      legacyPackages.nixified-ai = {
        internal = scripts;
        inherit container-tests;
        comfyui-container-gpu-test = nvidiaPkgs.callPackage ./vm-test/container-test.nix {
          nixosModule = inputs.self.nixosModules.comfyui;
        };
      };
    };
}
