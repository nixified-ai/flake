{ python3, python3Packages, applyPatches, writeShellScriptBin, src }:

let
  # getVersion = lib.flip lib.pipe [
  #   (src: builtins.readFile "${src}/fooocus_version.py")
  #   (builtins.match ".*version = '([0-9\.]+)'.*")
  #   builtins.head
  # ];

  python = with python3Packages; python3.withPackages (_: [
    torchsde
    torchvision
    einops
    transformers
    safetensors
    accelerate
    pyyaml
    pillow
    scipy
    tqdm
    psutil
    numpy
    pytorch-lightning
    omegaconf
    gradio
    pygit2
    opencv4
    httpx
  ]);

  patchedSource = applyPatches {
    name = "fooocus-source";
    inherit src;
    patches = [
      ./base_directory.patch
      ./no_prepare_environment.patch
    ];
  };

in

writeShellScriptBin "fooocus" ''
  if [ -d "/usr/lib/wsl/lib" ]
  then
      echo "Running via WSL (Windows Subsystem for Linux), setting LD_LIBRARY_PATH=/usr/lib/wsl/lib"
      set -x
      export LD_LIBRARY_PATH="/usr/lib/wsl/lib"
      set +x
  fi

  # See note about consumer GPUs:
  # https://docs.amd.com/bundle/ROCm-Deep-Learning-Guide-v5.4.3/page/Troubleshooting.html
  export HSA_OVERRIDE_GFX_VERSION=10.3.0

  mkdir -p ~/Fooocus
  cp -r --no-preserve=mode,ownership ${src}/models ~/Fooocus

  exec ${python}/bin/python ${patchedSource}/launch.py
''
