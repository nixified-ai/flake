{
  buildPythonPackage
, pythonRelaxDepsHook
, fetchFromGitHub
, stable-diffusion
, python
, lndir
, src

, taming-transformers-rom1504
, transformers
, k-diffusion

, realesrgan
, pillow

, addict
, future
, lmdb
, pyyaml
, scikitimage
, tqdm
, yapf
, gdown
, lpips
, fastapi
, lark
, analytics-python
, ffmpy
, markdown-it-py
, shap
, gradio
, fonts
, font-roboto
, piexif
, websockets
, codeformer
, blip
, deepdanbooru
, timm
, fairscale
, inflection

, diffusers
}@args:
let
  submodel = pkg: "${pkg}/${pkg.pythonModule.sitePackages or python.sitePackages}";
in
buildPythonPackage {
  pname = "stable-diffusion-webui";
  version = if src ? lastModifiedDate
    then builtins.substring 0 8 src.lastModifiedDate
    else "0";

  inherit src;

  patches = [
    ./path-hacks.patch
  ];

  stable_diffusion = stable-diffusion.src;
  taming_transformers = submodel taming-transformers-rom1504;
  k_diffusion = submodel k-diffusion;
  codeformer = "${submodel codeformer}/codeformer";
  blip = "${submodel blip}/blip";

  postPatch = ''
    substituteAll $setupPath setup.py

    mkdir repositories
    ln -s $stable_diffusion repositories/stable-diffusion
    substituteAllInPlace modules/paths.py
    mkdir -p models/{hypernetworks,Codeformer,ESRGAN,facelib/weights,GFPGAN,LDSR,SwinIR}

    for script_file in launch.py webui.py scripts/*.py; do
      sed -i '1 i #!/usr/bin/env python' $script_file
    done
  '';

  pythonRelaxDeps = [ "fairscale" "timm" "transformers" ];
  pythonRemoveDeps = [ "invisible-watermark" "opencv-python" ];

  dontRewriteSymlinks = true;

  inherit (python) sitePackages;
  dataPaths = [ "artists.csv" "models" "embeddings" "extensions" "textual_inversion_templates" "repositories" ];
  scriptDirs = [ "javascript" "localizations" ];
  scriptFiles = [ "style.css" "script.js" ];
  postInstall = ''
    install -d $out/lib/stable-diffusion-webui
    for data_path in $dataPaths; do
      mv $data_path $out/lib/stable-diffusion-webui/
    done
    for script_path in $scriptDirs; do
      install -d $out/lib/stable-diffusion-webui/$script_path
      lndir -silent $out/$sitePackages/$script_path $out/lib/stable-diffusion-webui/$script_path
    done
    for script_file in $scriptFiles; do
      ln -s $out/$sitePackages/$script_file $out/lib/stable-diffusion-webui/
    done

    substituteAll $wrapperPath $out/bin/webui
    chmod +x $out/bin/*
  '';

  passAsFile = [ "setup" "wrapper" ];
  setup = ''
    from io import open
    from glob import glob
    from setuptools import find_packages, setup

    with open('requirements.txt') as f:
      requirements = f.read().splitlines()

    setup(
      name='@pname@',
      version='@version@',
      install_requires=requirements,
      py_modules=['webui'],
      packages=['modules'] + glob('modules/*/'),
      scripts=[
        'launch.py', 'webui.py',
      ] + glob('scripts/*.py'),
      package_data = {
        'modules': [
          '../style.css',
          '../script.js',
          '../javascript/*.js',
          '../localizations/*.json',
        ],
      },
    )
  '';

  wrapper = ''
    if [[ -z ''${SD_WEBUI_SCRIPT_PATH-} ]]; then
      export SD_WEBUI_SCRIPT_PATH=''${XDG_DATA_HOME-$HOME/.local/share/stable-diffusion-webui}
    fi
    if [[ -d $SD_WEBUI_SCRIPT_PATH ]]; then
      find "$SD_WEBUI_SCRIPT_PATH" -type l -lname "${builtins.storeDir}/*-@pname@-*/*" -delete
    else
      mkdir -p "$SD_WEBUI_SCRIPT_PATH"
    fi
    cp -nr --no-preserve=mode @out@/lib/stable-diffusion-webui/* "$SD_WEBUI_SCRIPT_PATH"
    cd "$SD_WEBUI_SCRIPT_PATH"
    exec @out@/bin/webui.py "$@"
  '';

  nativeBuildInputs = [
    lndir
    pythonRelaxDepsHook
  ];
  propagatedBuildInputs = [
    stable-diffusion
    realesrgan
    diffusers
    pillow
    addict
    future
    lmdb
    pyyaml
    scikitimage
    tqdm
    yapf
    gdown
    lpips
    fastapi
    lark
    analytics-python
    ffmpy
    markdown-it-py
    shap
    gradio
    fonts
    font-roboto
    piexif
    websockets
    codeformer
    blip
    deepdanbooru
    timm
    fairscale
    inflection
  ];

  doCheck = false;

  meta = {
    description = "Stable Diffusion web UI";
    homepage = "https://github.com/AUTOMATIC1111/stable-diffusion-webui";
    mainProgram = "webui";
  };
}
