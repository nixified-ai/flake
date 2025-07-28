{
  lib,
  fetchFromGitHub,
  python3Packages,
  python3,
}: let
  fontend = python3Packages.callPackage ../comfyui-frontend/package.nix {};
  templates = python3Packages.callPackage ../comfyui-workflow-templates/package.nix {};
  docs = python3Packages.callPackage ../comfyui-embedded-docs/package.nix {};

  spandrel = python3Packages.callPackage ../../../../packages/spandrel/default.nix {};
in
  python3Packages.buildPythonApplication rec {
    pname = "comfyui";
    version = "0.3.56";

    src = fetchFromGitHub {
      owner = "comfyanonymous";
      repo = "ComfyUI";
      rev = "v${version}";
      hash = "sha256-pBfvBV4P1HOrEPGLtWXn7YamrW/ZM3fgMNWbgfjFSgc=";
    };

    dependencies = with python3Packages; [
      fontend
      templates
      docs
      torch
      torchsde
      torchvision
      torchaudio
      einops
      transformers
      tokenizers
      sentencepiece
      safetensors
      aiohttp
      pyyaml
      pillow
      scipy
      tqdm
      psutil
      alembic
      sqlalchemy
      av

      # optional dependencies
      kornia
      spandrel
      #    spandrel_extra_arches
      soundfile
    ];

    format = "other";

    buildPhase = "true";

    installPhase = ''
      mkdir -p $out/${python3.sitePackages}
      cp -r * $out/${python3.sitePackages}
    '';

    postPatch = ''
           substituteInPlace folder_paths.py \
             --replace-fail "os.path.dirname(os.path.realpath(__file__))" 'os.path.join(os.getenv("XDG_DATA_HOME", os.path.join(os.path.expanduser("~"), ".local", "share")), "comfyui")'

      #     substituteInPlace folder_paths.py \
      #       --replace-fail "os.path.dirname(os.path.realpath(__file__))" "os.getenv('COMFYUI_BASE_PATH')"
      #     substituteInPlace folder_paths.py \
      #       --replace-fail "os.path.dirname(os.path.realpath(__file__))" "os.getcwd()"
    '';

    nativeBuildInputs = [python3];

    postFixup = ''
      chmod +x $out/${python3.sitePackages}/main.py
      sed -i -e '1i#!/usr/bin/python' $out/lib/python3*/site-packages/main.py
      patchShebangs $out/${python3.sitePackages}/main.py

      mkdir $out/bin
      ln -s $out/lib/python3*/site-packages/main.py $out/bin/comfyui

      wrapProgram "$out/bin/comfyui" \
        --prefix PYTHONPATH : "$PYTHONPATH" \
    '';

    meta = with lib; {
      description = "The most powerful and modular stable diffusion GUI with a graph/nodes interface";
      homepage = "https://github.com/comfyanonymous/ComfyUI";
      license = licenses.gpl3Only;
      mainProgram = "comfyui";
      platforms = platforms.all;
    };
  }
