lib: {
  fixPackages = final: prev: let
    relaxProtobuf = pkg: pkg.overrideAttrs (old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [ final.pythonRelaxDepsHook ];
      pythonRelaxDeps = [ "protobuf" ];
    });
  in {
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
    streamlit = let
      streamlit = final.callPackage (final.pkgs.path + "/pkgs/applications/science/machine-learning/streamlit") {
        protobuf3 = final.protobuf;
      };
    in final.toPythonModule (relaxProtobuf streamlit);
    opencv-python-headless = final.opencv-python;
    opencv-python = final.opencv4;
  };

  torchRocm = final: prev: rec {
    # TODO: figure out how to patch torch-bin trying to access /opt/amdgpu
    # there might be an environment variable for it, can use a wrapper for that
    # otherwise just grep the world for /opt/amdgpu or something and substituteInPlace the path
    # you can run this thing without the fix by creating /opt and running nix build nixpkgs#libdrm --inputs-from . --out-link /opt/amdgpu
    torch-bin = prev.torch-bin.overrideAttrs (old: {
      src = final.pkgs.fetchurl {
        name = "torch-1.13.1+rocm5.1.1-cp310-cp310-linux_x86_64.whl";
        url = "https://download.pytorch.org/whl/rocm5.1.1/torch-1.13.1%2Brocm5.1.1-cp310-cp310-linux_x86_64.whl";
        hash = "sha256-qUwAL3L9ODy9hjne8jZQRoG4BxvXXLT7cAy9RbM837A=";
      };
      postFixup = (old.postFixup or "") + ''
        ${final.pkgs.gnused}/bin/sed -i s,/opt/amdgpu/share/libdrm/amdgpu.ids,/tmp/nix-pytorch-rocm___/amdgpu.ids,g $out/${final.python.sitePackages}/torch/lib/libdrm_amdgpu.so
      '';
      rocmSupport = true;
    });
    torchvision-bin = prev.torchvision-bin.overrideAttrs (old: {
      src = final.pkgs.fetchurl {
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
