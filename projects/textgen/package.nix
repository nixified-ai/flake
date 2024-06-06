{ python3Packages
, lib
, src
, writeShellScriptBin
, runCommand
, tmpDir ? "/tmp/nix-textgen"
, stateDir ? "$HOME/.textgen/state"
, libdrm
, cudaPackages
}:
let
  patchedSrc = runCommand "textgen-patchedSrc" { } ''
    cp -r --no-preserve=mode ${src} ./src
    cd src
    rm -rf models loras cache
    mv ./prompts ./_prompts
    mv ./characters ./_characters
    mv ./presets ./_presets
    mv ./training ./_training
    mv ./instruction-templates ./_instruction-templates
    cd -
    substituteInPlace ./src/modules/presets.py \
      --replace "Path('presets" "Path('$out/presets" \
      --replace "Path('prompts" "Path('$out/prompts" \
      --replace "Path(f'prompts" "Path(f'$out/prompts" \
      --replace "Path('extensions" "Path('$out/extensions" \
      --replace "Path(f'presets" "Path(f'$out/presets" \
      --replace "Path('softprompts" "Path('$out/softprompts" \
      --replace "Path(f'softprompts" "Path(f'$out/softprompts" \
      --replace "Path('characters" "Path('$out/characters" \
      --replace "Path('cache" "Path('$out/cache"
    substituteInPlace ./src/download-model.py \
      --replace "=args.output" "='$out/models/'" \
      --replace "base_folder=None" "base_folder='$out/models/'"
    substituteInPlace ./src/modules/html_generator.py \
      --replace "../css" "$out/css" \
      --replace 'Path(__file__).resolve().parent / ' "" \
      --replace "Path(f'css" "Path(f'$out/css"
    substituteInPlace ./src/modules/chat.py \
      --replace "folder = 'characters'" "folder = '$out/characters'" \
      --replace "Path('characters" "Path('$out/characters" \
      --replace "characters/" "$out/characters/" \
      --replace "folder = 'instruction-templates'" "folder = '$out/instruction-templates'" \
      --replace "Path(f'logs" "Path(f'${stateDir}/logs"
    substituteInPlace ./src/server.py \
      --replace "Path('presets" "Path('$out/presets" \
      --replace "Path('prompts" "Path('$out/prompts" \
      --replace "Path(f'prompts" "Path(f'$out/prompts" \
      --replace "Path('extensions" "Path('$out/extensions" \
      --replace "Path(f'presets" "Path(f'$out/presets" \
      --replace "Path('softprompts" "Path('$out/softprompts" \
      --replace "Path(f'softprompts" "Path(f'$out/softprompts" \
      --replace "Path('characters" "Path('$out/characters" \
      --replace "Path('cache" "Path('$out/cache"
    substituteInPlace ./src/modules/html_generator.py \
      --replace "../css" "$out/css" \
      --replace 'Path(__file__).resolve().parent / ' "" \
      --replace "Path(f'css" "Path(f'$out/css"
    substituteInPlace ./src/modules/utils.py \
      --replace "Path('css" "Path('$out/css" \
      --replace "Path('characters" "Path('$out/characters" \
      --replace "characters/" "$out/characters/" \
      --replace "Path('extensions" "Path('$out/extensions" \
      --replace "x.parts[1]" "x.parts[-2]" \
      --replace "path = \"instruction-templates\"" "path = \"$out/instruction-templates\"" \
      --replace "Path('presets" "Path('$out/presets" \
      --replace "Path(__file__).resolve().parent.parent" "Path('${stateDir}').resolve()" \
      --replace "Path(path).glob" "(Path('$out') / path).glob" \
      --replace "glob('txt')" "glob('*.txt')" \
      --replace "abs_path = Path(fname).resolve()" "abs_path = (Path(fname).resolve()) if Path(fname).is_absolute() else (root_folder / Path(fname))"
    substituteInPlace ./src/modules/prompts.py \
      --replace "Path(f'instruction-templates/" "Path(f'$out/instruction-templates/"
    substituteInPlace ./src/modules/training.py \
      --replace "Path(base_path)" "(Path(\"$out\") / base_path)" \
      --replace "'logs" "'${stateDir}/logs"
    substituteInPlace ./src/extensions/openai/completions.py \
      --replace "f\"instruction-templates" "f\"$out/instruction-templates"
    mv ./src $out
    ln -s ${stateDir}/models/ $out/models
    ln -s ${stateDir}/loras/ $out/loras
    ln -s ${stateDir}/cache/ $out/cache
    ln -s ${stateDir}/prompts/ $out/prompts
    ln -s ${stateDir}/characters/ $out/characters
    ln -s ${stateDir}/presets/ $out/presets
    ln -s ${stateDir}/training/ $out/training
    ln -s ${stateDir}/instruction-templates/ $out/instruction-templates
  '';
  textgenPython = python3Packages.python.withPackages (_: with python3Packages; [
    # autogptq # can't build this..
    accelerate
    bitsandbytes
    colorama
    datasets
    flexgen
    gradio
    llama-cpp-python
    markdown
    multiprocess
    nltk
    numpy
    pandas
    peft
    pillow
    pyarrow
    pyyaml
    requests
    rwkv
    safetensors
    scikit-learn
    sentence-transformers
    sentencepiece
    speechrecognition
    tiktoken
    torch
    torch-grammar
    wandb
    xxhash
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
(writeShellScriptBin "textgen" ''
  if [ -d "/usr/lib/wsl/lib" ]
  then
    echo "Running via WSL (Windows Subsystem for Linux), setting LD_LIBRARY_PATH"
    set -x
    export LD_LIBRARY_PATH="/usr/lib/wsl/lib"
    set +x
  fi
  rm -rf ${tmpDir}
  mkdir -p ${tmpDir}
  mkdir -p ${stateDir}/models ${stateDir}/cache ${stateDir}/loras ${stateDir}/prompts ${stateDir}/characters ${stateDir}/presets ${stateDir}/training ${stateDir}/instruction-templates
  cp -r --no-preserve=mode ${patchedSrc}/_prompts/* ${stateDir}/prompts/
  cp -r --no-preserve=mode ${patchedSrc}/_characters/* ${stateDir}/characters/
  cp -r --no-preserve=mode ${patchedSrc}/_presets/* ${stateDir}/presets/
  cp -r --no-preserve=mode ${patchedSrc}/_training/* ${stateDir}/training/
  cp -r --no-preserve=mode ${patchedSrc}/_instruction-templates/* ${stateDir}/instruction-templates/
  ln -s ${stateDir}/models/ ${tmpDir}/models
  ln -s ${stateDir}/loras/ ${tmpDir}/loras
  ln -s ${stateDir}/cache/ ${tmpDir}/cache
  ln -s ${stateDir}/prompts/ ${tmpDir}/prompts
  ln -s ${stateDir}/characters/ ${tmpDir}/characters
  ln -s ${stateDir}/presets/ ${tmpDir}/presets
  ln -s ${stateDir}/training/ ${tmpDir}/training
  ln -s ${stateDir}/instruction-templates/ ${tmpDir}/instruction-templates
  ${lib.optionalString (python3Packages.torch.rocmSupport or false) rocmInit}
  export LD_LIBRARY_PATH=/run/opengl-driver/lib:${cudaPackages.cudatoolkit}/lib
  ${textgenPython}/bin/python ${patchedSrc}/server.py $@ \
    --model-dir ${stateDir}/models/ \
    --lora-dir ${stateDir}/loras/ \

'').overrideAttrs
  (_: {
    meta = {
      maintainers = [ lib.maintainers.jpetrucciani ];
      license = lib.licenses.agpl3;
      description = "";
      homepage = "https://github.com/oobabooga/text-generation-webui";
      mainProgram = "textgen";
    };
  })
