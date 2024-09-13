{
  lib,
  mapCompatModelInstall,
  comfyuiTypes,
  python3,
  linkFarm,
  writers,
  writeTextFile,
  fetchFromGitHub,
  stdenv,
  models,
  customNodes,
  basePath ? "/var/lib/comfyui",
  inputPath ? "${basePath}/input",
  outputPath ? "${basePath}/output",
  tempPath ? "${basePath}/temp",
  userPath ? "${basePath}/user",
  extraArgs ? [],
}: let
  t = lib.types // comfyuiTypes;

  # aggregate all custom nodes' dependencies
  dependencies =
    lib.foldlAttrs
    ({
      pkgs,
      models,
    }: _: x: {
      pkgs = pkgs ++ (x.dependencies.pkgs or []);
      models = models // (x.dependencies.models or {});
    })
    {
      pkgs = [];
      models = {};
    }
    customNodes;

  # create a derivation for our custom nodes
  customNodesDrv =
    linkFarm "comfyui-custom-nodes"
    # check that all nodes are of the expected type
    (lib.mapAttrs (name: t.expectType t.customNode "custom node \"${name}\"") customNodes);

  # create a derivation for our models
  includedModels = models // dependencies.models;
  modelsDrv = let
    modelEntryF = mapCompatModelInstall (attrName: model: {
      name = t.expectType t.installPath "attribute name of model" attrName;
      path = t.expectType t.model "model resource for \"${attrName}\"" model;
    });
  in
    linkFarm "comfyui-models"
    (lib.mapAttrsToList modelEntryF
      (lib.warnIf (includedModels == {})
        "No models to install - the potential enjoyment you may derive from this ComfyUI setup will be limited"
        includedModels));

  config-data = {
    comfyui = let
      modelsDir = "${modelsDrv}";
      pathMap = path: rec {
        name = builtins.head (lib.splitString "/" path);
        value = "${modelsDir}/${name}";
      };
      subdirs = builtins.map pathMap (builtins.attrNames includedModels);
    in
      builtins.listToAttrs subdirs;
  };

  modelPathsFile = writeTextFile {
    name = "extra_model_paths.yaml";
    text = lib.generators.toYAML {} config-data;
  };

  pythonEnv = python3.withPackages (ps:
    with ps;
      [
        aiohttp
        einops
        kornia
        pillow
        psutil
        pyyaml
        safetensors
        scipy
        spandrel
        torch
        torchsde
        torchvision
        torchaudio
        tqdm
        transformers
      ]
      ++ dependencies.pkgs);

  executable = writers.writeDashBin "comfyui" ''
    ${pythonEnv}/bin/python $out/comfyui \
      --input-directory ${inputPath} \
      --output-directory ${outputPath} \
      --extra-model-paths-config ${modelPathsFile} \
      --temp-directory ${tempPath} \
      ${builtins.concatStringsSep " \\\n  " (extraArgs ++ ["$@"])}
  '';
in
  stdenv.mkDerivation {
    pname = "comfyui";
    version = "unstable-2024-09-09";

    src = fetchFromGitHub {
      owner = "comfyanonymous";
      repo = "ComfyUI";
      rev = "cd4955367e4170b88ba839efccb6d2ed0dd963ad";
      hash = "sha256-oEjsPznZxfTxT+m7Uvbsn+/ZiNAROfeUQMHNgYOAkvU=";
    };

    installPhase = ''
      runHook preInstall
      echo "Preparing bin folder"
      mkdir -p $out/bin/
      echo "Copying comfyui files"
      # These copies everything over but test/ci/github directories.  But it's not
      # very future-proof.  This can lead to errors such as "ModuleNotFoundError:
      # No module named 'app'" when new directories get added (which has happened
      # at least once).  Investigate if we can just copy everything.
      cp -r $src/comfy $out/
      cp -r $src/comfy_execution $out/
      cp -r $src/comfy_extras $out/
      cp -r $src/model_filemanager $out/
      cp -r $src/api_server $out/
      cp -r $src/app $out/
      cp -r $src/web $out/
      cp -r $src/*.py $out/
      mv $out/main.py $out/comfyui
      echo "Copying ${modelPathsFile} to $out"
      cp ${modelPathsFile} $out/extra_model_paths.yaml
      echo "Setting up custom nodes"
      ln -snf ${customNodesDrv} $out/custom_nodes
      echo "Symlinking models into installation dir for scripts that are unaware of extra_model_paths.yaml"
      ln -snf ${modelsDrv} $out/models
      echo "Copying executable script"
      cp ${executable}/bin/comfyui $out/bin/comfyui
      substituteInPlace $out/bin/comfyui --replace-warn "\$out" "$out"
      echo "Patching python code..."
      substituteInPlace $out/folder_paths.py --replace-warn "if not os.path.exists(input_directory):" "if False:"
      substituteInPlace $out/folder_paths.py --replace-warn 'os.path.join(os.path.dirname(os.path.realpath(__file__)), "user")' '"${userPath}"'
      runHook postInstall
    '';

    meta = with lib; {
      homepage = "https://github.com/comfyanonymous/ComfyUI";
      description = "The most powerful and modular stable diffusion GUI with a graph/nodes interface.";
      license = licenses.gpl3;
      platforms = platforms.all;
    };
  }
