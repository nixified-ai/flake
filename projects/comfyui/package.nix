{
  lib,
  python3,
  linkFarm,
  symlinkJoin,
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
}:
with builtins; let
  t = lib.types;
  expectType = ty: name: x:
    if ty.check x
    then x
    else let
      xtra =
        if lib.isAttrs x
        then "\ninstead it has attributes {${lib.concatStringsSep ", " (attrNames x)}}"
        else "";
    in
      throw "${name} (of type ${x._type or (builtins.typeOf x)}) was expected to be of type ${ty.description}${xtra}";

  expectModel = expectType (lib.mkOptionType {
    name = "comfyui-model";
    description = "ComfyUI model";
    check = m:
      lib.isAttrs m
      && (hasAttr "installPath" m && t.singleLineStr.check m.installPath)
      && (hasAttr "src" m && (t.package.check m.src || t.pathInStore.check m.src));
  });

  # aggregate all custom nodes' dependencies
  dependencies = lib.pipe customNodes [
    attrValues
    (map (v: v.dependencies))
    (foldl'
      ({
        pkgs,
        models,
      }: x: {
        pkgs = pkgs ++ (x.pkgs or []);
        models = models // (x.models or {});
      })
      {
        pkgs = [];
        models = {};
      })
  ];
  # create a derivation for our custom nodes
  customNodesDrv =
    expectType (t.attrsOf t.package)
    "customNodes" (linkFarm "comfyui-custom-nodes" customNodes);
  # create a derivation for our models
  modelsDrv = let
    mkComfyUIModel = name: {
      src,
      installPath,
      type ? null,
      base ? null,
    }:
      stdenv.mkDerivation {
        inherit src;
        name = src.name;
        phases = ["buildPhase"];
        buildPhase = ''
          dir=${builtins.dirOf (expectType t.singleLineStr "'installPath' attribute in argument to mkComfyUIModel" installPath)}
          mkdir -p $out/$dir
          ln -s $src $out/${installPath}
        '';
        meta = {
          model-type = type;
          base-model = base;
        };
      };
  in
    # WARN: this *replaces* existing paths when symlinking
    symlinkJoin {
      name = "comfyui-models";
      paths =
        lib.mapAttrsToList
        (name: m: mkComfyUIModel name (expectModel name m))
        (models // dependencies.models);
      postBuild = "echo links added";
    };

  config-data = {
    comfyui = let
      modelsDir = "${modelsDrv}";
    in {
      base_path = basePath;
      checkpoints = "${modelsDir}/checkpoints";
      clip = "${modelsDir}/clip";
      clip_vision = "${modelsDir}/clip_vision";
      configs = "${modelsDir}/configs";
      controlnet = "${modelsDir}/controlnet";
      embeddings = "${modelsDir}/embeddings";
      inpaint = "${modelsDir}/inpaint";
      ipadapter = "${modelsDir}/ipadapter";
      loras = "${modelsDir}/loras";
      upscale_models = "${modelsDir}/upscale_models";
      vae = "${modelsDir}/vae";
      vae_approx = "${modelsDir}/vae_approx";
    };
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
    version = "unstable-2024-06-12";

    src = fetchFromGitHub {
      owner = "comfyanonymous";
      repo = "ComfyUI";
      rev = "55ad9d5f8c8b906102313e894e471d2f5e833577";
      hash = "sha256-f/39ai/Ufvhqnzm7ZLuCQKJKVlQrqhNDdxyLiMK2zl4=";
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
      cp -r $src/comfy_extras $out/
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
