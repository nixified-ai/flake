{ python3Packages
# misc
, lib
, src
# extra deps
}:

let
  getVersion = lib.flip lib.pipe [
    (src: builtins.readFile "${src}/invokeai/version/invokeai_version.py")
    (builtins.match ".*__version__ = \"([^\"]+)\".*")
    builtins.head
  ];
in

python3Packages.buildPythonPackage {
  pname = "InvokeAI";
  format = "pyproject";
  version = getVersion src;
  inherit src;
  propagatedBuildInputs = with python3Packages; [
    semver
    mediapipe
    numpy
    torchsde
    uvicorn
    pyperclip
    invisible-watermark
    fastapi
    fastapi-events
    fastapi-socketio
    timm
    scikit-image
    controlnet-aux
    compel
    python-dotenv
    uvloop
    watchfiles
    httptools
    websockets
    dnspython
    albumentations
    opencv4
    pudb
    imageio
    imageio-ffmpeg
    compel
    npyscreen
    pytorch-lightning
    protobuf
    omegaconf
    test-tube
    einops
    taming-transformers-rom1504
    torch-fidelity
    torchmetrics
    transformers
    kornia
    k-diffusion
    picklescan
    diffusers
    pypatchmatch
    realesrgan
    pillow
    send2trash
    flask
    flask-cors
    dependency-injector
    gfpgan
    eventlet
    clipseg
    getpass-asterisk
    safetensors
    datasets
    accelerate
    huggingface-hub
    easing-functions
    dynamicprompts
    torchvision
    test-tube
  ];
  nativeBuildInputs = with python3Packages; [ pythonRelaxDepsHook pip ];
  pythonRemoveDeps = [ "clip" "pyreadline3" "flaskwebgui" "opencv-python" "fastapi-socketio" ];
  pythonRelaxDeps = [ "dnspython" "flask" "requests" "numpy" "pytorch-lightning" "torchsde" "uvicorn" "invisible-watermark" "accelerate" "scikit-image" "safetensors" "huggingface-hub" "torchvision" "test-tube" "fastapi" ];
  makeWrapperArgs = [
    '' --run '
      if [ -d "/usr/lib/wsl/lib" ]
      then
          echo "Running via WSL (Windows Subsystem for Linux), setting LD_LIBRARY_PATH=/usr/lib/wsl/lib"
          set -x
          export LD_LIBRARY_PATH="/usr/lib/wsl/lib"
          set +x
      fi
      '
    ''
    # See note about consumer GPUs:
    # https://docs.amd.com/bundle/ROCm-Deep-Learning-Guide-v5.4.3/page/Troubleshooting.html
    " --set-default HSA_OVERRIDE_GFX_VERSION 10.3.0"

    '' --run 'export INVOKEAI_ROOT="''${INVOKEAI_ROOT:-$HOME/invokeai}"' ''
    '' --run '
      if [[ ! -d "$INVOKEAI_ROOT" && "''${0##*/}" != invokeai-configure ]]
      then
        echo "State directory does not exist, running invokeai-configure"
        if [[ "''${NIXIFIED_AI_NONINTERACTIVE:-0}" != 0 ]]; then
          ${placeholder "out"}/bin/invokeai-configure --yes --skip-sd-weights
        else
          ${placeholder "out"}/bin/invokeai-configure
        fi
      fi
      '
    ''
  ];
  patchPhase = ''
    runHook prePatch

    substituteInPlace ./pyproject.toml \
      --replace 'setuptools~=65.5' 'setuptools' \
      --replace 'pip~=22.3' 'pip'

    # Add subprocess to the imports
    substituteInPlace ./invokeai/backend/install/invokeai_configure.py --replace \
        'import shutil' \
'
import shutil
import subprocess
'
    # shutil.copytree will inherit the permissions of files in the /nix/store
    # which are read only, so we subprocess.call cp instead and tell it not to
    # preserve the mode
    substituteInPlace ./invokeai/backend/install/invokeai_configure.py --replace \
      "shutil.copytree(configs_src, configs_dest, dirs_exist_ok=True)" \
      "subprocess.call('cp -r --no-preserve=mode {configs_src} {configs_dest}'.format(configs_src=configs_src, configs_dest=configs_dest), shell=True)"
    runHook postPatch

    substituteInPlace ./pyproject.toml \
      --replace 'pip~=22.3' 'pip' \
      --replace 'setuptools~=65.5' 'setuptools'
  '';
  meta = {
    description = "Fancy Web UI for Stable Diffusion";
    homepage = "https://invoke-ai.github.io/InvokeAI/";
    mainProgram = "invokeai-web";
  };
}
