{ aipython3
# misc
, lib
, src
# extra deps
, libdrm
, ninja
}:

let
  getVersion = lib.flip lib.pipe [
    (src: builtins.readFile "${src}/pyproject.toml")
    (builtins.match ".*version = \"([^\"]+)\".*")
    builtins.head
  ];
in

aipython3.buildPythonPackage {
  pname = "nerfstudio";
  format = "pyproject";

  version = getVersion src;
  inherit src;

  nativeBuildInputs = [ aipython3.pythonRelaxDepsHook ninja ];

  pythonRemoveDeps = [ "ninja" ];

  propagatedBuildInputs = with aipython3; [
    setuptools
    matplotlib
    pymeshlab
    pyquaternion
    appdirs
    python-socketio
    msgpack-numpy
    av
    nerfacc
    ipywidgets
    open3d
  ];

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
  ] ++ lib.optionals (aipython3.torch.rocmSupport or false) [
    '' --run '
      if [ ! -e /tmp/nix-pytorch-rocm___/amdgpu.ids ]
      then
          mkdir -p /tmp/nix-pytorch-rocm___
          ln -s ${libdrm}/share/libdrm/amdgpu.ids /tmp/nix-pytorch-rocm___/amdgpu.ids
      fi
      '
    ''
    # See note about consumer GPUs:
    # https://docs.amd.com/bundle/ROCm-Deep-Learning-Guide-v5.4.3/page/Troubleshooting.html
    " --set-default HSA_OVERRIDE_GFX_VERSION 10.3.0"
  ];

  meta = {
    description = "All-in-one repository for state-of-the-art NeRFs";
    homepage = "https://github.com/nerfstudio-project/nerfstudio";
    maintainers = [ lib.maintainers.lucasew ];
  };
}
