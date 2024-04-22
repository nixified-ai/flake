lib: {
  fixPackages = final: prev: let
    relaxProtobuf = pkg: pkg.overrideAttrs (old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [ final.pythonRelaxDepsHook ];
      pythonRelaxDeps = [ "protobuf" ];
    });
  in {
    invisible-watermark = prev.invisible-watermark.overridePythonAttrs {
      pythonImportsCheck = [ ];
    };
    torchsde = prev.torchsde.overridePythonAttrs { doCheck = false;
    pythonImportsCheck = []; };
    pytorch-lightning = relaxProtobuf prev.pytorch-lightning;
    wandb = relaxProtobuf (prev.wandb.overridePythonAttrs {
      doCheck = false;
    });
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
    streamlit = let
      streamlit = final.callPackage (final.pkgs.path + "/pkgs/applications/science/machine-learning/streamlit") {
        protobuf3 = final.protobuf;
      };
    in final.toPythonModule (relaxProtobuf streamlit);
    opencv-python-headless = final.opencv-python;
    opencv-python = final.opencv4;
  };

  pythonFinal = final: prev: {
    python = prev.python.override {
      # gives us a `python` where `python3Packages.python.pkgs` is the same package set as our `python3Packages`
      # with overrides applied
      packageOverrides = _: _: final;
    };
  };

  torchRocm = final: prev: {
    torch = prev.torch.override {
      cudaSupport = false;
      rocmSupport = true;
    };
  };

  torchCuda = final: prev: {
    torch = prev.torch.override {
      cudaSupport = true;
      rocmSupport = false;
    };
  };

  bitsAndBytesOldGpu = final: prev: {
    bitsandbytes = prev.bitsandbytes.overridePythonAttrs (old: {
      preBuild = old.preBuild + " cuda${final.torch.cudaPackages.cudaMajorVersion}x_nomatmul";
    });
  };
}
