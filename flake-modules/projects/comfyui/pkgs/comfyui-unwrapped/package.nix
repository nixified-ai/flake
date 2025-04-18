{ lib
, fetchFromGitHub
, python3Packages
, python3
, fetchzip
}:
let
  spandrel = python3Packages.callPackage ../../../../packages/spandrel/default.nix { };
  comfyui-workflow-templates = python3Packages.callPackage ../../../../packages/comfyui-workflow-templates/default.nix { };

  frontendVersion = "1.16.7"; # For some reason 1.16.8 was missing a release

  frontend = fetchzip {
    url = "https://github.com/Comfy-Org/ComfyUI_frontend/releases/download/v${frontendVersion}/dist.zip";
    hash = "sha256-5BPpa9lhNUTfseq4ySjZKsEKcTAPYRfuQyROnOHXdvg=";
    stripRoot = false;
  };
in
python3Packages.buildPythonApplication rec {
  pname = "comfyui";
  version = "0.3.29";

  src = fetchFromGitHub {
    owner = "comfyanonymous";
    repo = "ComfyUI";
    rev = "v${version}";
    hash = "sha256-tOZlpILmNsQXUDwti6j0q0xptmY42dcTL43RwdYgrMA=";
  };

  dependencies = with python3Packages; [
    comfyui-workflow-templates
    torch
    torchsde
    torchvision
    torchaudio
    numpy
    einops
    transformers
    tokenizers
    sentencepiece
    safetensors
    aiohttp
    yarl
    aiohttp
    pyyaml
    pillow
    scipy
    tqdm
    psutil
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

      substituteInPlace app/frontend_management.py \
        --replace-fail "return cls.init_frontend_unsafe(version_string)" "return \"${frontend}\""
  '';

  nativeBuildInputs = [ python3 ];

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
