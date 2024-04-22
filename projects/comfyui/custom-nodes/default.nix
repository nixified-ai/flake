{
  # I just took these from https://github.com/NixOS/nixpkgs/pull/268378 but I'm not sure about doing it this way
  custom-scripts-autocomplete-text ? (builtins.fetchurl {
    url = "https://gist.githubusercontent.com/pythongosssss/1d3efa6050356a08cea975183088159a/raw/a18fb2f94f9156cf4476b0c24a09544d6c0baec6/danbooru-tags.txt";
    sha256 = "15xmm538v0mjshncglpbkw2xdl4cs6y0faz94vfba70qq87plz4p";
  }),
  custom-scripts-data ? {
    name = "CustomScripts";
    logging = false;
  },
  lib,
  stdenv,
  fetchzip,
  writeText,
  fetchFromGitHub,
  fetchFromHuggingFace,
  python3Packages,
  models,
}: let
  # Patches don't apply to $src, and as with many scripting languages that don't
  # have a build output per se, we just want the script source itself placed
  # into $out.  So just copy everything into $out instead of from $src so we can
  # make sure we get everything in the future, and we use the patched versions.
  install = ''
    shopt -s dotglob
    shopt -s extglob
    cp -r ./!($out|$src) $out/
  '';
  mkComfyUICustomNodes = args:
    stdenv.mkDerivation ({
        installPhase = ''
          runHook preInstall
          mkdir -p $out/
          ${install}
          runHook postInstall
        '';

        passthru.dependencies = {
          pkgs = [];
          models = {};
        };
      }
      // args);
in {
  # https://github.com/Extraltodeus/ComfyUI-AutomaticCFG
  # automatically adjusts CFG to avoid burns
  # NOTE: while connected, your CFG won't be your CFG anymore. It is turned into a way to guide the CFG/final intensity/brightness/saturation.
  automatic-cfg = mkComfyUICustomNodes {
    pname = "comfyui-automatic-cfg";
    version = "unstable-2024-07-10";
    pyproject = true;
    passthru.dependencies.pkgs = with python3Packages; [
      colorama
    ];
    src = fetchFromGitHub {
      owner = "Extraltodeus";
      repo = "ComfyUI-AutomaticCFG";
      rev = "8ce450233e833eb2c7bbb0471a3c7bf9e51665e6";
      hash = "sha256-eq1GFcnSG8wRjdxCQwYFTvx/HItD5+VD0yA+CLHVP44=";
      fetchSubmodules = true;
    };
  };

  # Generates masks for inpainting based on text prompts..
  # https://github.com/biegert/ComfyUI-CLIPSeg
  clipseg = mkComfyUICustomNodes {
    pname = "comfyui-clipseg";
    version = "unstable-2023-04-12";
    pyproject = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp $src/custom_nodes/clipseg.py $out/__init__.py # https://github.com/biegert/ComfyUI-CLIPSeg/issues/12
      runHook postInstall
    '';
    src = fetchFromGitHub {
      owner = "biegert";
      repo = "ComfyUI-CLIPSeg";
      rev = "7f38951269888407de45fb934958c30c27704fdb";
      hash = "sha256-qqrl1u1wOKMRRBvMHD9gE80reDqLWn+vJEiM1yKZeUo=";
      fetchSubmodules = true;
    };
  };

  # Manages workflows in comfyui such that they can be version controlled
  # easily.
  # https://github.com/talesofai/comfyui-browser
  #
  # This uses a fork that allows for configurable directories.
  browser = mkComfyUICustomNodes {
    pname = "comfyui-browser";
    version = "unstable-fork-2024-04-21";
    src = fetchFromGitHub {
      owner = "LoganBarnett";
      repo = "comfyui-browser";
      rev = "209106316655a58b7f49695c0a0bcab57d5a0c0e";
      hash = "sha256-/vYCxzT0YvBiNl3B0s8na5QRYWxUgNUleRgCQrEJgvI=";
    };
    installPhase = ''
      mkdir -p $out/
      ${install}
      cp ${writeText "config.json" (builtins.toJSON {
        collections = "/var/lib/comfyui/comfyui-browser-collections";
        download_logs = "/var/lib/comfyui/comfyui-browser-download-logs";
        outputs = "/var/lib/comfyui/output";
        sources = "/var/lib/comfyui/comfyui-browser-sources";
      })} $out/config.json
    '';
  };

  # Show the time spent in various nodes of a workflow.
  profiler = mkComfyUICustomNodes {
    pname = "comfyui-profiler";
    version = "unstable-2024-01-11";
    src = fetchFromGitHub {
      owner = "tzwm";
      repo = "comfyui-profiler";
      rev = "942dfe484c481f7cdab8806fa278b3df371711bf";
      hash = "sha256-J0iTRycneGYF6RGJyZ/mVtEge1dxakwny0yfG1ceOd8=";
    };
  };

  # https://github.com/crystian/ComfyUI-Crystools
  # Various tools/nodes:
  # 1. Resources monitor (CUDA GPU usage, CPU usage, memory, etc).
  #   a. CUDA only.
  # 2. Progress monitor.
  # 3. Compare images.
  # 4. Compare workflow JSON documents.
  # 5. Debug values.
  # 6. Pipes - A means of condensing multiple inputs or outputs together into a
  #    single output or input (respectively).
  # 7. Better nodes for:
  #   a. Saving images.
  #   b. Loading images.
  #   c. See "hidden" data(?).
  # 8. New primitives (list), and possibly better/different replacements for
  #    original primitives.
  # 9. Switch - turn on or off functionality based on a boolean primitive.
  # 9. More™!
  #
  crystools = mkComfyUICustomNodes (let
    version = "1.12.0";
  in {
    pname = "comfyui-cystools";
    inherit version;
    src = fetchFromGitHub {
      owner = "crystian";
      repo = "ComfyUI-Crystools";
      rev = version;
      hash = "sha256-ZzbMgFeV5rrRU76r/wKnbhujoqE7UDOSaLgQZhguXuY=";
    };
    passthru.dependencies = {
      pkgs = with python3Packages; [
        deepdiff
        py-cpuinfo
        pynvml
      ];
    };
  });

  # https://github.com/pythongosssss/ComfyUI-Custom-Scripts
  # Various tools/nodes:
  # 1. Autocomplete of keywords, showing keyword count in the model.
  # 2. Auto-arrange graph.
  # 3. Always snap to grid.
  # 4. Loaders that show preview images, have example prompts, and are cataloged
  #    under folders.
  # 5. Checkpoint/LoRA metadata viewing.
  # 6. Image constraints (I assume for preview).
  # 7. Favicon for comfyui.
  # 8. Image feed showing images of the current session.
  # 9. Advanced KSampler denoise "helper" - asks for steps?
  # 10. Lock nodes and groups (groups doesn't have this in stock comfyui) to
  #     prevent moving.
  # 11. Math/eval expressions as a node.
  # 12. Node finder.
  # 13. Preset text - save and reuse text.
  # 14. Play sound node - great for notification of completion!
  # 15. Repeaters.
  # 16. Show text (can be good for loading images and getting the prompt text
  #     out).
  # 17. Show image on menu.
  # 18. String (replace) function - Substitution via regular expression or exact
  #     match.
  # 19. Save and load workflows (already in stock?).
  # 20. 90º reroutes...?
  # 21. Link render mode - linear, spline, straight.
  #
  custom-scripts = mkComfyUICustomNodes (let
    pysssss-config = writeText "pysssss.json" (lib.generators.toJSON {} custom-scripts-data);
  in {
    pname = "comfyui-custom-scripts";
    version = "unstable-2024-04-07";
    src = fetchFromGitHub {
      owner = "pythongosssss";
      repo = "ComfyUI-Custom-Scripts";
      rev = "3f2c021e50be2fed3c9d1552ee8dcaae06ad1fe5";
      hash = "sha256-Kc0zqPyZESdIQ+umepLkQ/GyUq6fev0c/Z7yyTew5dY=";
    };
    installPhase = ''
      runHook preInstall
      mkdir -p $out/
      cp -r $src/* $out/
      cp ${pysssss-config} $out/pysssss.json
      mkdir -p $out/user
      chmod +w $out/user
      cp ${custom-scripts-autocomplete-text} $out/user/autocomplete.txt
      chmod -w $out/user
      # Copy the patched version separately.  See
      # https://discourse.nixos.org/t/solved-how-to-apply-a-patch-in-a-flake/27227/4
      # for reference.  Perhaps a better reference exists?
      # But this doesn't work for reasons I can't understand.  I get permission
      # denied.
      # cp pysssss.py $out/
      # It seems that I need to grant myself write permissions first.  Is any of
      # this documented anywhere?
      chmod -R +w $out
      cp pysssss.py $out/
      cp __init__.py $out/
      # Put it back I guess?
      chmod -R -w $out/
      runHook postInstall
    '';
    patches = [
      ./custom-scripts-remove-js-install-step.patch
    ];
  });

  # https://github.com/dagthomas/comfyui_dagthomas
  # SDXL/SD3 prompt generator
  dagthomas = mkComfyUICustomNodes {
    pname = "comfyui_dagthomas";
    version = "unstable-2024-06-17";
    pyproject = true;
    src = fetchFromGitHub {
      owner = "dagthomas";
      repo = "comfyui_dagthomas";
      rev = "60d8d5fdf0ef69c9787144ad085f6833f02ef58d";
      sha256 = "sha256-SYBt0djVYHNKIBwiiQcpYeA7IS7/rBzzOvofEji0fDw=";
    };
    # TODO: surely there are dependencies
    # passthru.dependencies = {
    #   pkgs = with python3Packages; [
    #   ];
    # };
  };

  # https://github.com/LEv145/images-grid-comfy-plugin
  images-grid-comfy-plugin = mkComfyUICustomNodes (let
    version = "2.6";
  in {
    pname = "images-grid-comfy-plugin";
    inherit version;
    src = fetchFromGitHub {
      owner = "LEv145";
      repo = "images-grid-comfy-plugin";
      # Space character is deliberate.
      rev = "refs/tags/${version}";
      hash = "sha256-YG08pF6Z44y/gcS9MrCD/X6KqG99ig+VKLfZOd49w9s=";
    };
  });

  # https://github.com/Fannovel16/ComfyUI-Frame-Interpolation
  frame-interpolation = mkComfyUICustomNodes {
    pname = "comfyui-frame-interpolation";
    version = "unstable-2024-05-07";
    src = fetchFromGitHub {
      owner = "Fannovel16";
      repo = "ComfyUI-Frame-Interpolation";
      rev = "1c4c4b4f9a99e7e6eb7c5a5f3fdc7c9dfd319357";
      sha256 = "sha256-Qsx2GE7nDf4VDjS9KCzeUmJE5AR9IGm9i2DM5qmXswM=";
    };
    # also need models, e.g. https://github.com/styler00dollar/VSGAN-tensorrt-docker/releases/download/models/rife49.pth
    # see https://github.com/Fannovel16/ComfyUI-Frame-Interpolation/blob/main/vfi_utils.py#L96 for sources
    # and https://github.com/Fannovel16/ComfyUI-Frame-Interpolation/blob/main/vfi_models/rife/__init__.py for required models
    passthru.dependencies.pkgs = with python3Packages; [
      cupy
      einops
      kornia
      numpy
      opencv4
      pillow
      scipy
      torch
      torchvision
      tqdm
    ];
    meta.broken = true;
  };

  # https://github.com/Fannovel16/comfyui_controlnet_aux
  # Nodes for providing ControlNet hint images.
  controlnet-aux = mkComfyUICustomNodes {
    pname = "comfyui-controlnet-aux";
    version = "unstable-2024-06-21";
    pyproject = true;
    passthru.dependencies.pkgs = with python3Packages; [
      addict
      albumentations
      einops
      filelock
      ftfy
      fvcore
      importlib-metadata
      matplotlib
      mediapipe
      numpy
      omegaconf
      onnxruntime
      opencv4
      pillow
      python-dateutil
      pyyaml
      scikit-image
      scikit-learn
      scipy
      svglib
      torchvision
      trimesh
      yacs
      yapf
    ];

    # for some reason, this custom node has its own collection of models, so we
    # just go with it and put them where it expects, not bothering to add them
    # as general model dependencies.
    # TODO: there are probably more models to add
    installPhase = let
      yolox_l = fetchFromHuggingFace {
        owner = "yzd-v";
        repo = "DWPose";
        resource = "yolox_l.onnx";
        sha256 = "sha256-eGCued5siaPB63KumidWwMz74Et3kbtYgK+r2XhVpBE=";
      };
      yolo_nas_l_fp16 = fetchFromHuggingFace {
        owner = "hr16";
        repo = "yolo-nas-fp16";
        resource = "yolo_nas_l_fp16.onnx";
        sha256 = "sha256-wrdYscqpXXh3NoU5cdvJx2CDCA1oQUjFzRhbH9QON78=";
      };
      dw-ll_ucoco_384 = fetchFromHuggingFace {
        owner = "yzd-v";
        repo = "DWPose";
        resource = "dw-ll_ucoco_384.onnx";
        sha256 = "sha256-ck9P8kOe1hr7hvuKGVHsOcYiBoKAO0qL1PWYzZE7GEM=";
      };
      # https://huggingface.co/spaces/LiheYoung/Depth-Anything/resolve/main/checkpoints/depth_anything_vitb14.pth
      depth_anything = filename:
        import <nix/fetchurl.nix> {
          name = filename;
          # observed url when it tries to download on its own
          url = "https://cdn-lfs-us-1.huggingface.co/repos/b2/a8/b2a84b9a6ef705fba73e7ccec6a9728b3427d8b4c7f536eae186110f0cbd700f/64ae214ae4e27424b644c49464c0aa243016f6f753d95097c8eb9ad0b9cb2d9b?response-content-disposition=inline%3B+filename*%3DUTF-8%27%27${filename}%3B+filename%3D%22${filename}%22%3B&Expires=1719406653&Policy=eyJTdGF0ZW1lbnQiOlt7IkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTcxOTQwNjY1M319LCJSZXNvdXJjZSI6Imh0dHBzOi8vY2RuLWxmcy11cy0xLmh1Z2dpbmdmYWNlLmNvL3JlcG9zL2IyL2E4L2IyYTg0YjlhNmVmNzA1ZmJhNzNlN2NjZWM2YTk3MjhiMzQyN2Q4YjRjN2Y1MzZlYWUxODYxMTBmMGNiZDcwMGYvNjRhZTIxNGFlNGUyNzQyNGI2NDRjNDk0NjRjMGFhMjQzMDE2ZjZmNzUzZDk1MDk3YzhlYjlhZDBiOWNiMmQ5Yj9yZXNwb25zZS1jb250ZW50LWRpc3Bvc2l0aW9uPSoifV19&Signature=XDSvjG3AZZEL66gSsa4R5uE9bWFOA-wbiqkG7eX3t57nrZjdMmhVBjZxuXrB5TV-jjP0ZX52fDUlfIqbPjmsknxQql3aqFftJOhvbu7D467ng6HDw54yuVlIZ7ZQ7Z5kOuyAt3WSNyRQdgPVFQtb7~nvZmAbUheHdZWysg9ArCgYCRyKTPlR2hwyns9xTPlXkihkEcFK1vuVOENWXmOok~0-Ri6lgTiqBDA8OCoRasgSoxBHyApHi8CWfoJRj-MpmqBDC48lsM8xDU3perWtZ6LPfmrPmJz-KnOqZ~Ou~tFdfGOLyf66hBKN0~JH08L7Fr6c6A1Bty9mtZUQ4iuN9Q__&Key-Pair-Id=K2FPYV99P2N66Q";
          sha256 = "sha256-ZK4hSuTidCS2RMSUZMCqJDAW9vdT2VCXyOua0LnLLZs=";
        };
      sk_model = fetchFromHuggingFace {
        owner = "lllyasviel";
        repo = "Annotators";
        resource = "sk_model.pth";
        sha256 = "sha256-xobO0qZmtIULS7bM8HSAMcPtqfgi3nOjS4l5lw2Q8MY=";
      };
      sk_model2 = fetchFromHuggingFace {
        owner = "lllyasviel";
        repo = "Annotators";
        resource = "sk_model2.pth";
        sha256 = "sha256-MKU0eBBh806Du5QGtDNdpP8mFsldIqWFwSRaqDY+dOA=";
      };
      anyline-mteed = fetchFromHuggingFace {
        # https://huggingface.co/TheMistoAI/MistoLine/resolve/main/Anyline/MTEED.pth
        owner = "TheMistoAI";
        repo = "MistoLine";
        resource = "Anyline/MTEED.pth";
        sha256 = "sha256-o8LYqM6UIlVceHFgvUY2LXYTJaVlMzwOP2pT4Lriq9s=";
      };
      depth_anything_vitb14 = depth_anything "depth_anything_vitb14.pth";
      depth_anything_vitl14 = depth_anything "depth_anything_vitl14.pth";
      depth_anything_vits14 = depth_anything "depth_anything_vits14.pth";
      depth_anything_v2_vitb = models.depth_anything_v2_vitb.src;
    in ''
      runHook preInstall
      mkdir -p $out/ckpts/yzd-v/DWPose
      mkdir -p $out/ckpts/LiheYoung/Depth-Anything/checkpoints
      mkdir -p $out/ckpts/depth-anything/Depth-Anything-V2-Base
      mkdir -p $out/ckpts/lllyasviel/Annotators
      mkdir -p $out/ckpts/TheMistoAI/MistoLine/Anyline
      mkdir -p $out/ckpts/hr16/yolo-nas-fp16
      ${install}
      ln -s ${yolox_l} $out/ckpts/yzd-v/DWPose/${yolox_l.name}
      ln -s ${dw-ll_ucoco_384} $out/ckpts/yzd-v/DWPose/${dw-ll_ucoco_384.name}
      ln -s ${depth_anything_vitb14} $out/ckpts/LiheYoung/Depth-Anything/checkpoints/${depth_anything_vitb14.name}
      ln -s ${depth_anything_vitl14} $out/ckpts/LiheYoung/Depth-Anything/checkpoints/${depth_anything_vitl14.name}
      ln -s ${depth_anything_vits14} $out/ckpts/LiheYoung/Depth-Anything/checkpoints/${depth_anything_vits14.name}
      ln -s ${depth_anything_v2_vitb} $out/ckpts/depth-anything/Depth-Anything-V2-Base/${depth_anything_v2_vitb.name}
      ln -s ${sk_model} $out/ckpts/lllyasviel/Annotators/${sk_model.name}
      ln -s ${sk_model2} $out/ckpts/lllyasviel/Annotators/${sk_model2.name}
      ln -s ${anyline-mteed} $out/ckpts/TheMistoAI/MistoLine/Anyline/${anyline-mteed.name}
      ln -s ${yolo_nas_l_fp16} $out/ckpts/hr16/yolo-nas-fp16/${yolo_nas_l_fp16.name}
      runHook postInstall
    '';

    src = fetchFromGitHub {
      owner = "Fannovel16";
      repo = "comfyui_controlnet_aux";
      rev = "6f1ba1c10df84af6d356119ccf4ebcf796a10e1c";
      sha256 = "sha256-IapmOgCha9iYP1ngaP4yjAaWANXY6UNGBh7QiM2WFQ0=";
      fetchSubmodules = true;
    };
  };

  # https://github.com/Acly/comfyui-inpaint-nodes
  # Provides nodes for doing better inpainting.
  inpaint-nodes = mkComfyUICustomNodes {
    pname = "comfyui-inpaint-nodes";
    version = "unstable-2024-08-09";
    pyproject = true;
    src = fetchFromGitHub {
      owner = "Acly";
      repo = "comfyui-inpaint-nodes";
      rev = "69e5f2a0c2d475b83c3d4911f1786107d337bdcb";
      sha256 = "sha256-bh52JG+Zee/5p/fHbn4Ajcofp1GqiNF8WlyurauaOZs=";
      fetchSubmodules = true;
    };
  };

  # https://github.com/cubiq/ComfyUI_essentials
  essentials = mkComfyUICustomNodes {
    pname = "comfyui-essentials";
    version = "unstable-2024-06-15";
    src = fetchFromGitHub {
      owner = "cubiq";
      repo = "ComfyUI_essentials";
      rev = "5f1fc52acb03196d683552ea780e5c5325396f18";
      sha256 = "sha256-9Xb9Iqww46qXlEtkA0lbz4zQRPzuN71T1NJjO4B2Rl8=";
    };
    passthru.dependencies = {
      pkgs = with python3Packages; [
        numba
        colour-science
        jsonschema
        pixeloe
        pooch
        pymatting
        rembg
      ];
    };
  };

  # https://github.com/kijai/ComfyUI-KJNodes
  kjnodes = mkComfyUICustomNodes {
    pname = "comfyui-kjnodes";
    version = "unstable-2024-06-25";
    src = fetchFromGitHub {
      owner = "kijai";
      repo = "ComfyUI-KJNodes";
      rev = "2ead4fae1dddfe65d951248d98a1ff11dd50ab7a";
      sha256 = "sha256-cEoeHmRWTXO8DYU09n+eio3nLQGVROXy9+YWh8szXxA=";
    };
    passthru.dependencies =
      lib.trivial.warn
      "not all deps for custom node kjnodes are satisfied (color-matcher, librosa) - some functionality will be unavailable" {
        pkgs = with python3Packages; [
          # color-matcher # doesn't exist
          # librosa # broken
          matplotlib
          numpy
          pillow
          scipy
        ];
      };
  };

  # https://github.com/Fannovel16/ComfyUI-Video-Matting
  # bg-fg separation
  video-matting = mkComfyUICustomNodes {
    pname = "comfyui-video-matting";
    version = "unstable-2024-06-20";
    pyproject = true;
    src = fetchFromGitHub {
      owner = "Fannovel16";
      repo = "ComfyUI-Video-Matting";
      rev = "dd5ff373c327ed9caa321bca54e4cab8104f3735";
      sha256 = "sha256-aR1Xt2aI70QIGOUmd7gfB6g3AFE1+E6gBgzq04DvEUQ=";
      fetchSubmodules = true;
    };

    installPhase = let
      # https://huggingface.co/briaai/RMBG-1.4/resolve/main/model.pth
      briaai_rmbg = fetchFromHuggingFace {
        owner = "briaai";
        repo = "RMBG-1.4";
        resource = "model.pth";
        sha256 = "sha256-iTwWw0Cx3a/JPnhFek2UGQ2ptxeRSfhXQoTIPK6/Xow=";
      };
    in ''
      runHook preInstall
      mkdir -p $out/ckpts
      ${install}
      ln -s ${briaai_rmbg} $out/ckpts/briaai_rmbg_v1.4.pth
      runHook postInstall
    '';

    passthru.dependencies = {
      pkgs = with python3Packages; [
        pillow
        einops
      ];
    };
  };

  # https://github.com/kijai/ComfyUI-IC-Light
  # TODO: this sort of depends on kjnodes in that it appears to be effectively unusable without it; add `passthru.dependencies.nodes`?
  # recommended additional nodes:
  #   - video-matting
  #   - kjnodes
  ic-light = mkComfyUICustomNodes {
    pname = "comfyui-ic-light";
    version = "unstable-2024-06-19";
    src = fetchFromGitHub {
      owner = "kijai";
      repo = "ComfyUI-IC-Light";
      rev = "476303a5a9926e7cf61b2b18567a416d0bdd8d8c";
      sha256 = "sha256-5s2liguOHNwIV9PywFCCbYzROd6KscwYtk+RHEAmPFs=";
    };
    passthru.dependencies = {
      pkgs = with python3Packages; [
        opencv-python
      ];
      models = {
        ic-light_fbc = {
          installPath = "unet/iclight_sd15_fbc.safetensors";
          src = fetchFromHuggingFace {
            owner = "lllyasviel";
            repo = "ic-light";
            resource = "iclight_sd15_fbc.safetensors";
            sha256 = "sha256-u4zO2qSUSxbPqDVq/LwsIXTMTEr1feGRJK4M3dDZaUc=";
          };
        };
        ic-light_fc = {
          installPath = "unet/iclight_sd15_fc.safetensors";
          src = fetchFromHuggingFace {
            owner = "lllyasviel";
            repo = "ic-light";
            resource = "iclight_sd15_fc.safetensors";
            sha256 = "sha256-oDP7qqLz94WfpqRHfuY+u/nBFr81adWBGFbSgH80aM0=";
          };
        };
        ic-light_fcon = {
          installPath = "unet/iclight_sd15_fcon.safetensors";
          src = fetchFromHuggingFace {
            owner = "lllyasviel";
            repo = "ic-light";
            resource = "iclight_sd15_fcon.safetensors";
            sha256 = "sha256-N2Uu8nAoyP25iCgwsWIeTmSNJuGcsgNaavjVLzptjYc=";
          };
        };
      };
    };
  };

  # https://github.com/cubiq/ComfyUI_InstantID
  # only for SD XL
  instantid = mkComfyUICustomNodes {
    pname = "comfyui-instantid";
    version = "unstable-2024-05-08";
    src = fetchFromGitHub {
      owner = "cubiq";
      repo = "ComfyUI_InstantID";
      rev = "d8c70a0cd8ce0d4d62e78653674320c9c3084ec1";
      sha256 = "sha256-zLS2X4bW62Gqo48qB8kONJI1L0+tVKHLZV/fC2B5M9c=";
    };
    passthru.dependencies = {
      pkgs = with python3Packages; [
        insightface
        onnxruntime
      ];
      models = {
        instantid = {
          installPath = "controlnet/instantid.safetensors";
          src = fetchFromHuggingFace {
            owner = "InstantX";
            repo = "InstantID";
            resource = "ControlNetModel/diffusion_pytorch_model.safetensors";
            sha256 = "sha256-yBJ76fF0EB69r+6ZZNhWtJtjRDXPbao5bT9ZPPC7uwU=";
          };
        };
        instantid-ipadapter = {
          installPath = "instantid/ip-adapter.bin";
          src = fetchFromHuggingFace {
            owner = "InstantX";
            repo = "InstantID";
            resource = "ip-adapter.bin";
            sha256 = "sha256-ArNhjjbYA3hBZmYFIAmAiagTiOYak++AAqp5pbHFRuE=";
          };
        };
        antelopev2 = {
          installPath = "insightface/models/antelopev2";
          src = fetchzip {
            url = "https://huggingface.co/MonsterMMORPG/tools/resolve/main/antelopev2.zip";
            sha256 = "sha256-pUEM9LcVmTUemvglPZxiIvJd18QSDjxTEwAjfIWZ93g=";
          };
        };
      };
    };
  };

  # https://github.com/cubiq/ComfyUI_IPAdapter_plus
  # This allows use of IP-Adapter models (IP meaning Image Prompt in this
  # context).  IP-Adapter models can out-perform fine tuned models
  # (checkpoints?).
  ipadapter-plus = mkComfyUICustomNodes {
    pname = "comfyui-ipadapter-plus";
    version = "unstable-2024-06-9";
    pyproject = true;
    src = fetchFromGitHub {
      owner = "cubiq";
      repo = "ComfyUI_IPAdapter_plus";
      rev = "7d8adaec730bff243cc3026eed5111695cc5ed4e";
      sha256 = "sha256-F0mmJ2X+eEijsV24s9I+zP90wpNC9pu8IwdEzq0xj8M=";
      fetchSubmodules = true;
    };

    passthru.dependencies = {
      pkgs = with python3Packages; [
        insightface
        onnxruntime
      ];
      models = {
        inherit (models) inswapper_128;
        buffalo_l = {
          installPath = "insightface/models/buffalo_l";
          src = fetchzip {
            url = "https://github.com/deepinsight/insightface/releases/download/v0.7/buffalo_l.zip";
            sha256 = "sha256-ayiIkXXgg83aPhAFs2WXvDxHqKizpVuAKF2AjZyjct4=";
            stripRoot = false;
          };
        };
      };
    };
  };

  # https://github.com/Acly/comfyui-tooling-nodes
  # Make ComfyUI more friendly towards API usage.
  tooling-nodes = mkComfyUICustomNodes {
    pname = "comfyui-tooling-nodes";
    version = "unstable-2024-08-09";
    pyproject = true;
    installPhase = let
      safety-checker = import <nix/fetchurl.nix> {
        name = "model.safetensors";
        url = "https://huggingface.co/CompVis/stable-diffusion-safety-checker/resolve/refs%2Fpr%2F41/model.safetensors";
        sha256 = "sha256-CJAvGbHP69fJifFS/AUHvvaJjHBqkdZmUJODEiMktRE=";
      };
    in ''
      runHook preInstall
      mkdir -p $out/safetychecker
      ${install}
      ln -s ${safety-checker} $out/safetychecker/${safety-checker.name}
      runHook postInstall
    '';
    src = fetchFromGitHub {
      owner = "Acly";
      repo = "comfyui-tooling-nodes";
      rev = "d1dcf12f1007f3067b3128361dd5729d244fb25f";
      sha256 = "sha256-6FPv+UutUkI5IQpL+4FDKLq5G2/zsRXd/YtiDjK2/Pc=";
      fetchSubmodules = true;
    };
  };

  # Handle upscaling of smaller images into larger ones.  This is helpful to go
  # from a prototyped image to a highly detailed, high resolution version.
  ultimate-sd-upscale = mkComfyUICustomNodes {
    pname = "comfyui-ultimate-sd-upscale";
    version = "unstable-2024-03-30";
    src = fetchFromGitHub {
      owner = "ssitu";
      repo = "ComfyUI_UltimateSDUpscale";
      rev = "b303386bd363df16ad6706a13b3b47a1c2a1ea49";
      sha256 = "sha256-kcvhafXzwZ817y+8LKzOkGR3Y3QBB7Nupefya6s/HF4=";
      fetchSubmodules = true;
    };
  };

  ## Broken due to runtime mischief
  # https://github.com/Gourieff/comfyui-reactor-node
  # Fast and simple face swap node(s).
  reactor-node = mkComfyUICustomNodes {
    pname = "comfyui-reactor-node";
    version = "unstable-2024-04-07";
    pyproject = true;
    passthru.dependencies = {
      pkgs = with python3Packages; [
        insightface
        onnxruntime
      ];
      models = {
        # expects these directories to exist:
        #   models/reactor/faces
        #   models/facerestore_models
        #   models/ultralytics/bbox
        #   models/ultralytics/segm
        #   models/sams
        # but it also seems to want arbitrary write-access to the models dir......

        inherit
          (models)
          inswapper_128
          "GFPGANv1.3"
          "GFPGANv1.4"
          "codeformer-v0.1.0"
          GPEN-BFR-512
          ;
      };
    };

    src = fetchFromGitHub {
      owner = "Gourieff";
      repo = "comfyui-reactor-node";
      rev = "05bf228e623c8d7aa5a33d3a6f3103a990cfe09d";
      sha256 = "sha256-2IrpOp7N2GR1zA4jgMewAp3PwTLLZa1r8D+/uxI8yzw=";
      fetchSubmodules = true;
    };

    meta.broken = true;
  };

  # https://github.com/JettHu/ComfyUI-TCD
  tcd = mkComfyUICustomNodes {
    pname = "comfyui-tcd";
    version = "0.1.0";
    pyproject = true;
    src = fetchFromGitHub {
      owner = "JettHu";
      repo = "ComfyUI-TCD";
      rev = "9f6f9cd10169775ac3b5a757b2afa696c43f8251";
      sha256 = "sha256-5OLVWkNtgeivK9f1KyjpastT6U4xOQ+KenI48Sv8ies=";
    };
  };
}
