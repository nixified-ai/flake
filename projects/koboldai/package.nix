{ aipython3
, lib
, src
, wsl ? false
, fetchFromGitHub
, writeShellScriptBin
, runCommand
, tmpDir ? "/tmp/nix-koboldai"
, stateDir ? "$HOME/.koboldai/state"
, libdrm
}:
let
  overrides = {
    transformers = aipython3.transformers.overrideAttrs (old: rec {
       propagatedBuildInputs = old.propagatedBuildInputs ++ [ aipython3.huggingface-hub ];
       pname = "transformers";
       version = "4.24.0";
       src = fetchFromGitHub {
         owner = "huggingface";
         repo = pname;
         rev = "refs/tags/v${version}";
         hash = "sha256-aGtTey+QK12URZcGNaRAlcaOphON4ViZOGdigtXU1g0=";
       };
    });
    bleach = aipython3.bleach.overrideAttrs (old: rec {
       pname = "bleach";
       version = "4.1.0";
       src = fetchFromGitHub {
         owner = "mozilla";
         repo = pname;
         rev = "refs/tags/v${version}";
         hash = "sha256-YuvH8FvZBqSYRt7ScKfuTZMsljJQlhFR+3tg7kABF0Y=";
       };
    });
  };
  # The original kobold-ai program wants to write models settings and user
  # scripts to the current working directory, but tries to write to the
  # /nix/store erroneously due to mismanagement of the current working
  # directory in its source code. The patching below replicates the original
  # functionality of the program by making symlinks in the source code
  # directory that point to ${tmpDir}
  #
  # The wrapper script we have made for the program will then create another
  # symlink that points to ${stateDir}, ultimately the default symlink trail
  # looks like the following
  #
  # /nix/store/kobold-ai/models -> /tmp/nix-koboldai -> ~/.koboldai/state
  patchedSrc = runCommand "koboldAi-patchedSrc" {} ''
    cp -r --no-preserve=mode ${src} ./src
    cd src
    rm -rf models settings userscripts
    cd -
    substituteInPlace ./src/aiserver.py \
      --replace 'os.system("")' 'STATE_DIR = os.path.expandvars("${stateDir}")' \
      --replace 'cache_dir="cache"' "cache_dir=os.path.join(STATE_DIR, 'cache')" \
      --replace 'shutil.rmtree("cache/")' 'shutil.rmtree(os.path.join(STATE_DIR, "cache"))' \
      --replace "app.config['SESSION_TYPE'] = 'filesystem'" "app.config['SESSION_TYPE'] = 'memcached'"

    # https://stackoverflow.com/questions/59433832/runtimeerror-only-tensors-of-floating-point-dtype-can-require-gradients
    # Typo in casing by author means that breakmodels crash the program, but
    # correcting the case from tensor -> Tensor fixes it
    substituteInPlace ./src/breakmodel.py --replace "torch.tensor" "torch.Tensor"
    mv ./src $out
    ln -s ${tmpDir}/models/ $out/models
    ln -s ${tmpDir}/settings/ $out/settings
    ln -s ${tmpDir}/userscripts/ $out/userscripts
  '';
  koboldPython = aipython3.python.withPackages (_: with aipython3; [
    overrides.bleach
    overrides.transformers
    colorama
    flask
    flask-socketio
    flask-session
    eventlet
    dnspython
    markdown
    sentencepiece
    protobuf
    marshmallow
    loguru
    termcolor
    psutil
    torch-bin
    torchvision-bin
    apispec
    apispec-webframeworks
    lupa
    memcached
  ]);

  # See note about consumer GPUs:
  # https://docs.amd.com/bundle/ROCm-Deep-Learning-Guide-v5.4.3/page/Troubleshooting.html
  rocmInit = ''
    if [ ! -e /tmp/nix-pytorch-rocm___/amdgpu.ids ]
    then
        mkdir -p /tmp/nix-pytorch-rocm___
        ln -s ${libdrm}/share/libdrm/amdgpu.ids /tmp/nix-pytorch-rocm___/amdgpu.ids
    fi
    export HSA_OVERRIDE_GFX_VERSION=''${HSA_OVERRIDE_GFX_VERSION-'10.3.0'}
  '';
in
(writeShellScriptBin "koboldai" ''
  if [ -d "/usr/lib/wsl/lib" ]
  then
    echo "Running via WSL (Windows Subsystem for Linux), setting LD_LIBRARY_PATH"
    set -x
    export LD_LIBRARY_PATH="/usr/lib/wsl/lib"
    set +x
  fi
  rm -rf ${tmpDir}
  mkdir -p ${tmpDir}
  mkdir -p ${stateDir}/models ${stateDir}/cache ${stateDir}/settings ${stateDir}/userscripts
  ln -s ${stateDir}/models/   ${tmpDir}/models
  ln -s ${stateDir}/settings/ ${tmpDir}/settings
  ln -s ${stateDir}/userscripts/ ${tmpDir}/userscripts
  ${lib.optionalString (aipython3.torch.rocmSupport or false) rocmInit}
  ${koboldPython}/bin/python ${patchedSrc}/aiserver.py $@
'').overrideAttrs
  (_: {
    meta = {
      maintainers = [ lib.maintainers.matthewcroughan ];
      license = lib.licenses.agpl3;
      description = "browser-based front-end for AI-assisted writing with multiple local & remote AI models";
      homepage = "https://github.com/KoboldAI/KoboldAI-Client";
      mainProgram = "koboldai";
    };
  })
