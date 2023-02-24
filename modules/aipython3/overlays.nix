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
    # TODO: figure out how to patch torch-bin trying to access /opt/amdgpu
    # there might be an environment variable for it, can use a wrapper for that
    # otherwise just grep the world for /opt/amdgpu or something and substituteInPlace the path
    # you can run this thing without the fix by creating /opt and running nix build nixpkgs#libdrm --inputs-from . --out-link /opt/amdgpu
    torch-bin = prev.torch-bin.overrideAttrs (old: {
      src = pkgs.fetchurl {
        name = "torch-1.13.1+rocm5.1.1-cp310-cp310-linux_x86_64.whl";
        url = "https://download.pytorch.org/whl/rocm5.1.1/torch-1.13.1%2Brocm5.1.1-cp310-cp310-linux_x86_64.whl";
        hash = "sha256-qUwAL3L9ODy9hjne8jZQRoG4BxvXXLT7cAy9RbM837A=";
      };
    });
    torchvision-bin = prev.torchvision-bin.overrideAttrs (old: {
      src = pkgs.fetchurl {
        name = "torchvision-0.14.1+rocm5.1.1-cp310-cp310-linux_x86_64.whl";
        url = "https://download.pytorch.org/whl/rocm5.1.1/torchvision-0.14.1%2Brocm5.1.1-cp310-cp310-linux_x86_64.whl";
        hash = "sha256-8CM1QZ9cZfexa+HWhG4SfA/PTGB2475dxoOtGZ3Wa2E=";
      };
    });
    torch = torch-bin;
    torchvision = torchvision-bin;
  };

  torchCuda = final: prev: {
    torch = final.torch-bin;
    torchvision = final.torchvision-bin;
  };
}
