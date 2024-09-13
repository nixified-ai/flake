{
  config,
  lib,
  ...
}: let
  l = lib // config.flake.lib;
  inherit (config.flake) overlays;
in {
  perSystem = {
    config,
    pkgs,
    lib,
    self',
    ...
  }: let
    commonOverlays = [
      (final: prev: {
        opencv-python-headless = final.opencv-python;
        opencv-python = final.opencv4;
      })
      (l.overlays.callManyPackages [
        ../../packages/mediapipe
        ../../packages/gguf
        ../../packages/spandrel
        ../../packages/colour-science
        ../../packages/rembg
        ../../packages/pixeloe
      ])
      # what gives us a python with the overlays actually applied
      overlays.python-pythonFinal
    ];

    python3Variants = {
      amd = l.overlays.applyOverlays pkgs.python311Packages (commonOverlays
        ++ [
          overlays.python-torchRocm
        ]);
      nvidia = l.overlays.applyOverlays pkgs.python311Packages (commonOverlays
        ++ [
          # FIXME: temporary standin for practical purposes.
          # They're prebuilt and come with cuda support.
          (final: prev: {
            torch = prev.torch-bin;
            torchaudio = prev.torchaudio-bin;
            torchvision = prev.torchvision-bin;
          })
          # use this when things stabilise and we feel ready to build the whole thing
          # overlays.python-torchCuda
        ]);
    };

    inherit (self'.legacyPackages.air) fetchair modelTypes ecosystemOf ecosystems baseModels;
    inherit
      (import ./model-installers.nix {
        inherit lib fetchair ecosystemOf modelTypes;
        inherit (pkgs) fetchurl;
      })
      installModels
      typeFromInstallPath
      ;
    comfyuiTypes = import ./types.nix {inherit lib;};
    kritaModelInstalls = import ./krita-models.nix {inherit installModels ecosystems baseModels;};

    hospice = import ./hospice.nix {inherit lib typeFromInstallPath ecosystemOf baseModels;};

    # we require a python3 with an appropriately overridden package set depending on GPU
    mkComfyUIVariant = python3: args:
      pkgs.callPackage ./package.nix ({
          inherit python3 comfyuiTypes;
          inherit (hospice) mapCompatModelInstall;
        }
        // args);

    # gpu-dependent packages
    pkgsFor = vendor:
      rec {
        # make available the python package set used so that user-defined custom nodes can depend on it
        python3Packages = python3Variants."${vendor}";

        comfyui = mkComfyUIVariant python3Packages.python {
          customNodes = {};
          models = {};
        };
        krita-server = comfyui.override {
          models = kritaModelInstalls.default;
          customNodes = kritaCustomNodes;
        };
        krita-server-full = krita-server.override {models = kritaModelInstalls.full;};
        krita-server-minimal = krita-server.override {models = kritaModelInstalls.required;};

        customNodes = import ./custom-nodes {
          inherit lib python3Packages;
          inherit (pkgs) stdenv fetchFromGitHub fetchzip writeText;
        };
        # subset of `customNodes` used by Krita plugin
        kritaCustomNodes = {
          inherit
            (customNodes)
            comfyui-gguf
            controlnet-aux
            inpaint-nodes
            ipadapter-plus
            tooling-nodes
            ultimate-sd-upscale
            ;
        };
      }
      # include all other packages as well to make it more convenient
      // builtins.removeAttrs self'.legacyPackages.comfyui ["amd" "nvidia"];
    amd = pkgsFor "amd";
    nvidia = pkgsFor "nvidia";
  in {
    legacyPackages.comfyui = {
      inherit
        amd
        nvidia
        installModels
        kritaModelInstalls
        modelTypes
        ecosystems
        baseModels
        ;
      types = comfyuiTypes;
      inherit
        (comfyuiTypes)
        isModel
        isCustomNode
        ;

      inherit (hospice) fetchFromHuggingFace; # deprecated
      models = throw ''
        This flake no longer provides a library of models beyond those needed for the Krita plugin;
        instead it provides the convenient `installModels` function which makes it super easy to install models you add yourself.
        Use `installModels` on your model set; see the flake-provided template for examples.
        (If you relied on a model you liked from the library, copy its url and hash and add it to your own set. You can find the old library here:
        https://github.com/lboklin/nixified-ai/blob/54afce4505ef64fd3c4b993f1807fbb6dff14391/projects/comfyui/models/default.nix.)
      '';
      kritaModels = throw ''
        These model sets are now available in `kritaModelInstalls`, but they are now indexed by their install path, so any explicit inherits will need to be updated.
      '';
    };

    packages = {
      comfyui-amd = amd.comfyui;
      comfyui-nvidia = nvidia.comfyui;

      krita-comfyui-server-amd = amd.krita-server;
      krita-comfyui-server-amd-full = amd.krita-server-full;
      krita-comfyui-server-amd-minimal = amd.krita-server-minimal;
      krita-comfyui-server-nvidia = nvidia.krita-server;
      krita-comfyui-server-nvidia-full = nvidia.krita-server-full;
      krita-comfyui-server-nvidia-minimal = nvidia.krita-server-minimal;
    };
  };
}
