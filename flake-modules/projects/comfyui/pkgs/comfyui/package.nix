{
  symlinkJoin,
  makeWrapper,
  python3Packages,
  stdenv,
  writeTextFile,
  comfyuiPackages,
  lib,
  linkFarm,
  writeShellScript,
  withCustomNodes ? [],
  withModels ? [],
}:
let
  customNodes = withCustomNodes;
  models = withModels;

  # TODO: Maybe we should have a golden test, to check whether new folders have been unexpectedly added upstream
  supportedFolders = lib.attrNames (builtins.readDir (comfyuiPackages.comfyui-unwrapped.src + "/models"));

  unsupportedFolders = lib.flatten (map (f: f.comfyui.installPaths) models);

  createModelsDir = models: let
    # Creates entires for the second linkFarm argument like:
    # [ { name = "hello-test"; path = pkgs.hello; } ]
    linkFarmEntries = builtins.concatMap (modelDrv:
      map (installPath: let
        name = "${python3Packages.python.sitePackages}/models/${installPath}/${modelDrv.name}";
        traceMessage = ''
          installPath "${installPath}" for "${modelDrv.name}" does not occur in the models folder upstream, so may be unused comfyui at runtime
        '';
        checkedName = lib.warnIfNot (lib.elem installPath supportedFolders) traceMessage name;
      in {
        name = checkedName;
        path = modelDrv;
      }) modelDrv.passthru.comfyui.installPaths
    ) models;
  in linkFarm "comfyui-models" linkFarmEntries;

  modelPathsFile = let
    modelsDir = "${createModelsDir models}/${python3Packages.python.sitePackages}";
  in writeTextFile {
    name = "extra_model_paths.yaml";
    text = lib.generators.toYAML {} ({ comfyui = ((lib.genAttrs (supportedFolders ++ unsupportedFolders) (nodeName: "${modelsDir}/models/${nodeName}")) // { custom_nodes = "@CUSTOM_NODES@"; }); });
  };
in
symlinkJoin {
  name = "comfyui-wrapped";
  paths = [
    comfyuiPackages.comfyui-unwrapped
   (createModelsDir models)
  ] ++ customNodes;
  propagatedBuildInputs = [
  ] ++ customNodes;
  nativeBuildInputs = [
    makeWrapper
  ];
  postBuild = let
    preStartScript = writeShellScript "comfyui-wrapped-prestart.sh" ''
      echo ${toString supportedFolders}
      set -x
      DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}/comfyui"
      mkdir -p "$DATA_HOME"
      cp -rT ${comfyuiPackages.comfyui-unwrapped.src} "$DATA_HOME"
      chmod -R +w "$DATA_HOME"
    '';
  in ''
    rm $out/bin/comfyui
    cp ${comfyuiPackages.comfyui-unwrapped}/bin/comfyui $out/bin/comfyui
    chmod +w $out/bin/comfyui
    echo $PYTHONPATH
    wrapProgram $out/bin/comfyui \
      --run ${preStartScript} \
      --prefix PYTHONPATH : "$PYTHONPATH" \
      --add-flags "--extra-model-paths-config $out/bin/extra_model_paths.yaml"
      cp --no-preserve=mode ${modelPathsFile} $out/bin/extra_model_paths.yaml
    substituteInPlace $out/bin/extra_model_paths.yaml --replace-fail "@CUSTOM_NODES@" "$out/${python3Packages.python.sitePackages}/custom_nodes"
  '';
  meta = {
    mainProgram = "comfyui";
  };
  passthru = {
    # TODO: Make this exist and be composable. Multiple applications like
    # (x.withCustomNodes (n: [])).withModels (m: []) doesn't work.
    #
    # withCustomNodes = nodesFunction: comfyuiPackages.comfyui.override {
    #   customNodes = nodesFunction comfyuiPackages;
    # };
    # withModels = function: comfyuiPackages.comfyui.override {
    #   comfyuiModels = function comfyuiPackages;
    # };
    pkgs = comfyuiPackages;
    mkComfyUICustomNode =
      let
        install = name: ''
          mkdir -p $out/${python3Packages.python.sitePackages}/custom_nodes/${name}
          shopt -s dotglob
          shopt -s extglob
          cp -r ./!($out|$src) $out/${python3Packages.python.sitePackages}/custom_nodes/${name}
        '';
      in
      args:
      stdenv.mkDerivation (
        {
          installPhase = ''
            runHook preInstall
            mkdir -p $out/
            ${install args.name or args.pname}
            runHook postInstall
          '';
        }
        // args
      );
  };
}
