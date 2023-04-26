{ aipython3
, lib
, src
, wsl ? false
, fetchFromGitHub
, writeShellScriptBin
, runCommand
, tmpDir ? "/tmp/nix-textgen"
, stateDir ? "$HOME/.textgen/state"
, libdrm
}:
let
  overrides = { };
  patchedSrc = runCommand "textgen-patchedSrc" { } ''
    cp -r --no-preserve=mode ${src} ./src
    cd src
    rm -rf models loras cache
    mv ./prompts ./_prompts
    cd -
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
    substituteInPlace ./src/download-model.py \
      --replace "=args.output" "='$out/models/'" \
      --replace "base_folder=None" "base_folder='$out/models/'"
    mv ./src $out
    ln -s ${tmpDir}/models/ $out/models
    ln -s ${tmpDir}/loras/ $out/loras
    ln -s ${tmpDir}/cache/ $out/cache
    ln -s ${tmpDir}/prompts/ $out/prompts
  '';
  textgenPython = aipython3.python.withPackages (_: with aipython3; [
    accelerate
    bitsandbytes
    colorama
    datasets
    flexgen
    gradio
    llama-cpp-python
    markdown
    numpy
    pandas
    peft
    pillow
    pyyaml
    requests
    rwkv
    safetensors
    sentencepiece
    tqdm
    transformers
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
  mkdir -p ${stateDir}/models ${stateDir}/cache ${stateDir}/loras ${stateDir}/prompts
  cp ${patchedSrc}/_prompts/* ${stateDir}/prompts/.
  ln -s ${stateDir}/models/ ${tmpDir}/models
  ln -s ${stateDir}/loras/ ${tmpDir}/loras
  ln -s ${stateDir}/cache/ ${tmpDir}/cache
  ln -s ${stateDir}/prompts/ ${tmpDir}/prompts
  ${lib.optionalString (aipython3.torch.rocmSupport or false) rocmInit}
  ${textgenPython}/bin/python ${patchedSrc}/server.py $@ \
    --model-dir ${stateDir}/models/ \
    --lora-dir ${stateDir}/loras/ \
    --disk-cache-dir ${stateDir}/cache/
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
