{ aipython3
# dependencies
, streamlit
# misc
, lib
, src
# configuration
, wsl ? false
}:

let
  getVersion = lib.flip lib.pipe [
    (src: builtins.readFile "${src}/setup.py")
    (builtins.match ".+VERSION = '([^']+)'.+")
    builtins.head
  ];
in

aipython3.buildPythonPackage {
  pname = "InvokeAI";
  version = getVersion src;
  inherit src;
  propagatedBuildInputs = with aipython3; [
    numpy
    albumentations
    opencv4
    pudb
    imageio
    imageio-ffmpeg
    pytorch-lightning
    protobuf
    omegaconf
    test-tube
    ((streamlit.overrideAttrs (old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [ pythonRelaxDepsHook ];
      pythonRelaxDeps = [ "protobuf" ];
    })).override { protobuf3 = protobuf; })
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
    flask-socketio
    flask-cors
    dependency-injector
    gfpgan
    eventlet
    clipseg
    getpass-asterisk
  ];
  nativeBuildInputs = [ aipython3.pythonRelaxDepsHook ];
  pythonRemoveDeps = [ "clip" "pyreadline3" "flaskwebgui" ];
  pythonRelaxDeps = [ "protobuf" ];
  postFixup = ''
    ${lib.optionalString wsl "makeWrapperArgs+=( --set LD_LIBRARY_PATH '/usr/lib/wsl/lib' )"}
    chmod +x $out/bin/*
    wrapPythonPrograms
  '';
  doCheck = false;
  meta = {
    description = "Fancy Web UI for Stable Diffusion";
    homepage = "https://invoke-ai.github.io/InvokeAI/";
    mainProgram = "invoke.py";
  };
}
