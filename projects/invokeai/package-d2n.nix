{
  config,
  lib,
  dream2nix,
  inputs,
  ...
}: let
  pyproject = lib.pipe (config.mkDerivation.src + /pyproject.toml) [
    builtins.readFile
    builtins.fromTOML
  ];

in {
  imports = [
    dream2nix.modules.drv-parts.mach-nix-xs
  ];

  name = "invokeai";
  version = "0.0.0";

  deps = {nixpkgs, ...}: {
    inherit (nixpkgs)
      breakpointHook
      fetchurl
      gcc-unwrapped
      glib
      xorg
      zlib
      ;
  };

  buildPythonPackage = {
    format = "pyproject";
  };

  mkDerivation = {
    src = inputs.invokeai-src;
    buildInputs = [
      config.deps.python.pkgs.setuptools
    ];
    patchPhase = ''
      runHook prePatch

      # Add subprocess to the imports
      substituteInPlace ./ldm/invoke/config/invokeai_configure.py --replace \
          'import shutil' \
      '
      import shutil
      import subprocess
      '
      # shutil.copytree will inherit the permissions of files in the /nix/store
      # which are read only, so we subprocess.call cp instead and tell it not to
      # preserve the mode
      substituteInPlace ./ldm/invoke/config/invokeai_configure.py --replace \
        "shutil.copytree(configs_src, configs_dest, dirs_exist_ok=True)" \
        "subprocess.call('cp -r --no-preserve=mode {configs_src} {configs_dest}'.format(configs_src=configs_src, configs_dest=configs_dest), shell=True)"
      runHook postPatch
    '';
    postFixup = ''
      chmod +x $out/bin/*
      wrapPythonPrograms
    '';
  };

  env = {
    autoPatchelfIgnoreMissingDeps = [
      "libcuda.so.1"
      "libtbb.so.12"
    ];
    makeWrapperArgs = [
      '' --run '
        if [ -d "/usr/lib/wsl/lib" ]
        then
            echo "Running via WSL (Windows Subsystem for Linux), setting LD_LIBRARY_PATH=/usr/lib/wsl/lib"
            set -x
            export LD_LIBRARY_PATH="/usr/lib/wsl/lib"
            set +x
        fi
        '
      ''
    ];
  };

  mach-nix.pythonSources.fetch-pip = {
    pypiSnapshotDate = "2023-04-02";
    # remove last (windows only) requirement due to dream2nix splitting issue
    requirementsList = lib.init pyproject.project.dependencies;
  };

  mach-nix.manualSetupDeps = {
    basicsr = [
      "lmdb"
      "yapf"
      "tb-nightly"
      "tqdm"
      "scikit-image"
      "scipy"
      "opencv-python"
    ];
  };

  mach-nix.drvs = {
    antlr4-python3-runtime.nixpkgs-overrides.enable = false;
    test-tube = {
      mkDerivation.doCheck = false;
      mkDerivation.doInstallCheck = false;
    };

    urwid = {
      mkDerivation.doCheck = lib.mkForce false;
    };

    filterpy = {
      mkDerivation.doCheck = false;
    };

    basicsr = {
      mkDerivation = {
        nativeBuildInputs = [
          config.deps.python.pkgs.cython
          config.deps.python.pkgs.numpy
          config.deps.python.pkgs.torch
          config.deps.breakpointHook
        ];
        dontStrip = true;
        doCheck = false;
      };
      buildPythonPackage = {
        pipInstallFlags = [
          "--ignore-installed"
        ];
        catchConflicts = false;
      };
    };
  };
}
