pkgs: {
  fixPackages = final: prev: {
    pytorch-lightning = prev.pytorch-lightning.overrideAttrs (old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [ final.pythonRelaxDepsHook ];
      pythonRelaxDeps = [ "protobuf" ];
    });
    wandb = prev.wandb.overrideAttrs (old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [ final.pythonRelaxDepsHook ];
      pythonRelaxDeps = [ "protobuf" ];
    });
    scikit-image = final.scikitimage;
    #overriding because of https://github.com/NixOS/nixpkgs/issues/196653
    opencv4 = prev.opencv4.override { openblas = pkgs.blas; };
  };

  extraDeps = final: prev: let
    rm = d: d.overrideAttrs (old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [ final.pythonRelaxDepsHook ];
      pythonRemoveDeps = [ "opencv-python-headless" "opencv-python" "tb-nightly" "clip" ];
    });
    callPackage = final.callPackage;
    rmCallPackage = path: args: rm (callPackage path args);
  in {
    apispec-webframeworks = callPackage ../../packages/apispec-webframeworks { };
    pydeprecate = callPackage ../../packages/pydeprecate { };
    taming-transformers-rom1504 =
      callPackage ../../packages/taming-transformers-rom1504 { };
    albumentations = rmCallPackage ../../packages/albumentations { opencv-python-headless = final.opencv4; };
    qudida = rmCallPackage ../../packages/qudida { opencv-python-headless = final.opencv4; };
    gfpgan = rmCallPackage ../../packages/gfpgan { opencv-python = final.opencv4; };
    basicsr = rmCallPackage ../../packages/basicsr { opencv-python = final.opencv4; };
    facexlib = rmCallPackage ../../packages/facexlib { opencv-python = final.opencv4; };
    realesrgan = rmCallPackage ../../packages/realesrgan { opencv-python = final.opencv4; };
    codeformer = callPackage ../../packages/codeformer { opencv-python = final.opencv4; };
    clipseg = rmCallPackage ../../packages/clipseg { opencv-python = final.opencv4; };
    filterpy = callPackage ../../packages/filterpy { };
    kornia = callPackage ../../packages/kornia { };
    lpips = callPackage ../../packages/lpips { };
    ffmpy = callPackage ../../packages/ffmpy { };
    shap = callPackage ../../packages/shap { };
    picklescan = callPackage ../../packages/picklescan { };
    diffusers = callPackage ../../packages/diffusers { };
    pypatchmatch = callPackage ../../packages/pypatchmatch { };
    fonts = callPackage ../../packages/fonts { };
    font-roboto = callPackage ../../packages/font-roboto { };
    analytics-python = callPackage ../../packages/analytics-python { };
    markdown-it-py = callPackage ../../packages/markdown-it-py { };
    gradio = callPackage ../../packages/gradio { };
    hatch-requirements-txt = callPackage ../../packages/hatch-requirements-txt { };
    timm = callPackage ../../packages/timm { };
    blip = callPackage ../../packages/blip { };
    fairscale = callPackage ../../packages/fairscale { };
    torch-fidelity = callPackage ../../packages/torch-fidelity { };
    resize-right = callPackage ../../packages/resize-right { };
    torchdiffeq = callPackage ../../packages/torchdiffeq { };
    k-diffusion = callPackage ../../packages/k-diffusion { clean-fid = final.clean-fid; };
    accelerate = callPackage ../../packages/accelerate { };
    clip-anytorch = callPackage ../../packages/clip-anytorch { };
    jsonmerge = callPackage ../../packages/jsonmerge { };
    clean-fid = callPackage ../../packages/clean-fid { };
    getpass-asterisk = callPackage ../../packages/getpass-asterisk { };
  };

  torchRocm = final: prev: rec {
  };

  torchCuda = final: prev: {
    torch = final.torch-bin;
    torchvision = final.torchvision-bin;
  };
}
