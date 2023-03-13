{ aipython3
, lib
, src
, fetchFromGitHub
, lndir
, stateDir ? "$HOME/.koboldai/state"
}:
let
  pythonPackages = aipython3.overrideScope (final: prev: {
    transformers = prev.transformers.overrideAttrs (old: rec {
       propagatedBuildInputs = old.propagatedBuildInputs ++ [ final.huggingface-hub ];
       pname = "transformers";
       version = "4.24.0";
       src = fetchFromGitHub {
         owner = "huggingface";
         repo = pname;
         rev = "refs/tags/v${version}";
         hash = "sha256-aGtTey+QK12URZcGNaRAlcaOphON4ViZOGdigtXU1g0=";
       };
    });
    bleach = prev.bleach.overrideAttrs (old: rec {
       pname = "bleach";
       version = "4.1.0";
       src = fetchFromGitHub {
         owner = "mozilla";
         repo = pname;
         rev = "refs/tags/v${version}";
         hash = "sha256-YuvH8FvZBqSYRt7ScKfuTZMsljJQlhFR+3tg7kABF0Y=";
       };
    });
  });
in pythonPackages.buildPythonPackage {
  pname = "koboldai";
  version = if src ? lastModifiedDate
    then builtins.substring 0 8 src.lastModifiedDate
    else "0";

  # The original kobold-ai program wants to write models settings and user
  # scripts to the current working directory, but tries to write to the
  # /nix/store erroneously due to mismanagement of the current working
  # directory in its source code.
  #
  # The wrapper script we have made for the program will initialize ${stateDir}
  # as an appropriate working directory to run from.

  inherit src;
  patches = [
    ./state-path.patch
  ];

  doCheck = false;
  dontRewriteSymlinks = true;

  passAsFile = [ "setup" "wrapper" ];
  inherit stateDir;
  postPatch = ''
    substituteAll $setupPath setup.py

    substituteAllInPlace aiserver.py \
      --replace 'shutil.rmtree("cache/")' 'shutil.rmtree(CACHE_DIR)' \
      --replace 'cache_dir="cache"' "cache_dir=CACHE_DIR"

    sed -i -e 's|^git\+.*/mkultra$|mkultra|' requirements.txt
  '';

  staticPaths = [
    "colab" "maps" "static" "templates"
    "cores" "extern"
  ];
  sharedPaths = [
    "models" "userscripts" "settings" "stories"
  ];
  inherit (pythonPackages.python) sitePackages;
  postInstall = ''
    substituteAll $wrapperPath $out/bin/koboldai
    chmod +x $out/bin/*

    install -d $out/lib/$pname
    for static_path in $staticPaths *.lua; do
      mv $static_path $out/$sitePackages/
      ln -s $out/$sitePackages/$static_path $out/lib/$pname/
    done

    for shared_path in $sharedPaths; do
      install -d $out/lib/$pname/$shared_path
      if [[ -e $out/$sitePackages/$shared_path ]]; then
        lndir -silent $out/$sitePackages/$shared_path $out/lib/$pname/$shared_path
      fi
    done
  '';

  propagatedBuildInputs = with pythonPackages; [
    bleach
    transformers
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
    accelerate
  ];

  nativeBuildInputs = [
    lndir
    pythonPackages.pythonRelaxDepsHook
  ];

  pythonRemoveDeps = [ "mkultra" "flask-ngrok" "flask-cloudflared" ];
  pythonRelaxDeps = [ "dnspython" "lupa" "torch" "transformers" ];

  setup = ''
    from io import open
    from glob import glob
    from setuptools import find_packages, setup

    with open('requirements.txt') as f:
      requirements = f.read().splitlines()

    py_modules = [m.removesuffix('.py') for m in glob('*.py')]
    py_modules.remove('setup')
    py_modules.remove('aiserver')
    setup(
      name='@pname@',
      version='@version@',
      install_requires=requirements,
      py_modules=py_modules,
      scripts=[
        'aiserver.py',
      ],
    )
  '';

  wrapper = ''
    set -eu

    if [ -d "/usr/lib/wsl/lib" ]; then
      echo "Running via WSL (Windows Subsystem for Linux), setting LD_LIBRARY_PATH"
      set -x
      export LD_LIBRARY_PATH="/usr/lib/wsl/lib"
      set +x
    fi

    if [[ -d @stateDir@ ]]; then
      find @stateDir@ -type l -lname "${builtins.storeDir}/*-@pname@-*/*" -delete
    else
      mkdir -p @stateDir@
    fi
    cd @stateDir@

    cp -nr --no-preserve=mode @out@/lib/@pname@/* ./
    mkdir -p cache

    exec @out@/bin/aiserver.py "$@"
  '';

  meta = {
    maintainers = [ lib.maintainers.matthewcroughan ];
    license = lib.licenses.agpl3;
    description = "browser-based front-end for AI-assisted writing with multiple local & remote AI models";
    homepage = "https://github.com/KoboldAI/KoboldAI-Client";
    mainProgram = "koboldai";
  };
  passthru = {
    inherit pythonPackages;
  };
}
