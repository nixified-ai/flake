pkgs: {
  fixPackages = final: prev:
    let
      relaxProtobuf = pkg: pkg.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs ++ [ final.pythonRelaxDepsHook ];
        pythonRelaxDeps = [ "protobuf" ];
      });
    in
    {
      tokenizers =
        let
          inherit (prev.pkgs) fetchFromGitHub rustPlatform;
          pname = "tokenizers";
          version = "0.13.2";
          sourceRoot = "source/bindings/python";
        in
        prev.tokenizers.overridePythonAttrs (_: rec {
          src = fetchFromGitHub {
            owner = "huggingface";
            repo = pname;
            rev = "python-v${version}";
            hash = "sha256-DE0DA9U9CVQH5dp8BWgeXb+RdkXXOH2dZ9NrPGScDsQ=";
          };

          cargoDeps = rustPlatform.fetchCargoTarball {
            inherit src sourceRoot;
            name = "${pname}-${version}";
            hash = "sha256-G6BQpnGucqmbmADC47xV0Jm9JqYob7416FFHl8rRWh4=";
          };
        });
      typing-extensions =
        let
          inherit (prev.pkgs) fetchPypi;
          version = "4.5.0";
        in
        prev.typing-extensions.overridePythonAttrs (_: {
          src = fetchPypi {
            pname = "typing_extensions";
            inherit version;
            hash = "sha256-XLX0p5E51plgez72IqHe2vqE4RWrACTg2cBEqUecp8s=";
          };
        });
      pytorch-lightning = relaxProtobuf prev.pytorch-lightning;
      wandb = relaxProtobuf prev.wandb;
      markdown-it-py = prev.markdown-it-py.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs ++ [ final.pythonRelaxDepsHook ];
        pythonRelaxDeps = [ "linkify-it-py" ];
        passthru = old.passthru // {
          optional-dependencies = with final; {
            linkify = [ linkify-it-py ];
            plugins = [ mdit-py-plugins ];
          };
        };
      });
      filterpy = prev.filterpy.overrideAttrs (old: {
        doInstallCheck = false;
      });
      shap = prev.shap.overrideAttrs (old: {
        doInstallCheck = false;
        propagatedBuildInputs = old.propagatedBuildInputs ++ [ final.packaging ];
        pythonImportsCheck = [ "shap" ];

        meta = old.meta // {
          broken = false;
        };
      });
      streamlit =
        let
          streamlit = final.callPackage (pkgs.path + "/pkgs/applications/science/machine-learning/streamlit") {
            protobuf3 = final.protobuf;
          };
        in
        final.toPythonModule (relaxProtobuf streamlit);
    };

  extraDeps = final: prev:
    let
      rm = d: d.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs ++ [ final.pythonRelaxDepsHook ];
        pythonRemoveDeps = [ "opencv-python-headless" "opencv-python" "tb-nightly" "clip" ];
      });
      callPackage = final.callPackage;
      rmCallPackage = path: args: rm (callPackage path args);
    in
    {
      scikit-image = final.scikitimage;
      opencv-python-headless = final.opencv-python;
      opencv-python = final.opencv4;

      safetensors = callPackage ../../packages/safetensors { };
      compel = callPackage ../../packages/compel { };
      apispec-webframeworks = callPackage ../../packages/apispec-webframeworks { };
      pydeprecate = callPackage ../../packages/pydeprecate { };
      taming-transformers-rom1504 =
        callPackage ../../packages/taming-transformers-rom1504 { };
      albumentations = rmCallPackage ../../packages/albumentations { };
      qudida = rmCallPackage ../../packages/qudida { };
      gfpgan = rmCallPackage ../../packages/gfpgan { };
      basicsr = rmCallPackage ../../packages/basicsr { };
      facexlib = rmCallPackage ../../packages/facexlib { };
      realesrgan = rmCallPackage ../../packages/realesrgan { };
      codeformer = callPackage ../../packages/codeformer { };
      clipseg = rmCallPackage ../../packages/clipseg { };
      kornia = callPackage ../../packages/kornia { };
      lpips = callPackage ../../packages/lpips { };
      ffmpy = callPackage ../../packages/ffmpy { };
      picklescan = callPackage ../../packages/picklescan { };
      diffusers = callPackage ../../packages/diffusers { };
      pypatchmatch = callPackage ../../packages/pypatchmatch { };
      fonts = callPackage ../../packages/fonts { };
      font-roboto = callPackage ../../packages/font-roboto { };
      analytics-python = callPackage ../../packages/analytics-python { };
      gradio = callPackage ../../packages/gradio { };
      blip = callPackage ../../packages/blip { };
      fairscale = callPackage ../../packages/fairscale { };
      torch-fidelity = callPackage ../../packages/torch-fidelity { };
      resize-right = callPackage ../../packages/resize-right { };
      torchdiffeq = callPackage ../../packages/torchdiffeq { };
      k-diffusion = callPackage ../../packages/k-diffusion { };
      accelerate = callPackage ../../packages/accelerate { };
      clip-anytorch = callPackage ../../packages/clip-anytorch { };
      clean-fid = callPackage ../../packages/clean-fid { };
      getpass-asterisk = callPackage ../../packages/getpass-asterisk { };
      peft = callPackage ../../packages/peft { };
      llama-cpp-python = callPackage ../../packages/llama-cpp-python { };
      bitsandbytes = callPackage ../../packages/bitsandbytes { };
      lion-pytorch = callPackage ../../packages/lion-pytorch { };
      flexgen = callPackage ../../packages/flexgen { };
      hf-doc-builder = callPackage ../../packages/hf-doc-builder { };
      rwkv = callPackage ../../packages/rwkv { };
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
      postFixup = (old.postFixup or "") + ''
        ${pkgs.gnused}/bin/sed -i s,/opt/amdgpu/share/libdrm/amdgpu.ids,/tmp/nix-pytorch-rocm___/amdgpu.ids,g $out/${final.python.sitePackages}/torch/lib/libdrm_amdgpu.so
      '';
      rocmSupport = true;
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
