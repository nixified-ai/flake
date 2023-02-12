{ inputs, lib, ... }:

{
  perSystem = { config, pkgs, ... }: let
    inherit (config.dependencySets) aipython3-amd aipython3-nvidia;

    getVersion = lib.flip lib.pipe [
      (src: builtins.readFile "${src}/setup.py")
      (builtins.match ".+VERSION = '([^']+)'.+")
      builtins.head
    ];

    mkInvokeAIVariant = aipython3: aipython3.buildPythonPackage rec {
      pname = "InvokeAI";
      version = getVersion src;
      src = inputs.invokeai-src;
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
        ((pkgs.streamlit.overrideAttrs (old: {
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
        chmod +x $out/bin/*
        wrapPythonPrograms
      '';
      doCheck = false;
      meta = {
        description = "Fancy Web UI for Stable Diffusion";
        homepage = "https://invoke-ai.github.io/InvokeAI/";
        mainProgram = "invoke.py";
      };
    };

  in {
    packages = {
      invokeai-amd = mkInvokeAIVariant aipython3-amd;
      invokeai-nvidia = mkInvokeAIVariant aipython3-nvidia;
    };
  };
}
