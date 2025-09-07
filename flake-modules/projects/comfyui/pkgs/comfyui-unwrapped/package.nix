{
  lib,
  fetchFromGitHub,
  python3Packages,
  python3,
}:
let
  av = python3Packages.callPackage ../../../../packages/av/default.nix { };
  spandrel = python3Packages.callPackage ../../../../packages/spandrel/default.nix { };
  comfyui-frontend-package =
    python3Packages.callPackage ../../../../packages/comfyui-frontend-package/default.nix
      { };
  comfyui-embedded-docs =
    python3Packages.callPackage ../../../../packages/comfyui-embedded-docs/default.nix
      { };
in
python3Packages.buildPythonApplication rec {
  pname = "comfyui";
  version = "unstable-2025-09-06";

  src = fetchFromGitHub {
    owner = "comfyanonymous";
    repo = "ComfyUI";
    rev = "ea6cdd2631fbca6ed81b95796150c32c9a029f0d";
    hash = "sha256-DEM+6NCvUVwBkD2Jtb7WVEVVc3tyCaUc383DXPLN9Mg=";
  };

  patches = [
    ./follow-symlinks-in-extensions.patch
    ./dont_use_cudnn_backend.patch
  ];

  dependencies = with python3Packages; [
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

    yarl
    av
    numpy
    comfyui-frontend-package
    comfyui-embedded-docs

    # optional dependencies
    kornia
    spandrel
    #    spandrel_extra_arches
    soundfile
    pydantic
    pydantic-settings
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
