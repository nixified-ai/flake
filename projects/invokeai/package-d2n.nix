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
    dream2nix.modules.dream2nix.pip
  ];

  paths.package = "/projects/invokeai";

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
    tbb = nixpkgs.tbb_2021_8;
  };

  buildPythonPackage = {
    format = "pyproject";
    # works around a problem in nixpkgs.
    # TODO: remove once this is merged: https://github.com/NixOS/nixpkgs/pull/254547
    catchConflicts = false;
  };

  mkDerivation = {
    src = inputs.invokeai-src;
    buildInputs = [
    ];
    # patchPhase = ''
    #   runHook prePatch

    #   # Add subprocess to the imports
    #   substituteInPlace ./ldm/invoke/config/invokeai_configure.py --replace \
    #       'import shutil' \
    #   '
    #   import shutil
    #   import subprocess
    #   '
    #   # shutil.copytree will inherit the permissions of files in the /nix/store
    #   # which are read only, so we subprocess.call cp instead and tell it not to
    #   # preserve the mode
    #   substituteInPlace ./ldm/invoke/config/invokeai_configure.py --replace \
    #     "shutil.copytree(configs_src, configs_dest, dirs_exist_ok=True)" \
    #     "subprocess.call('cp -r --no-preserve=mode {configs_src} {configs_dest}'.format(configs_src=configs_src, configs_dest=configs_dest), shell=True)"
    #   runHook postPatch
    # '';
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

  pip = {
    pypiSnapshotDate = "2023-08-17";
    # remove last (windows only) requirement due to dream2nix splitting issue
    requirementsList =
      (lib.init pyproject.project.dependencies)
      ++ pyproject.build-system.requires
      ++ [
        "cython"
      ];
    pipVersion = "23.2.1";
    flattenDependencies = true;
    buildExtras = [
      "standard"
    ];
  };


  pip.drvs.numba.mkDerivation.buildInputs = [
    config.deps.tbb
  ];

  pip.drvs.triton.mkDerivation.nativeBuildInputs = [
    config.deps.python.pkgs.pythonRelaxDepsHook
  ];

  pip.drvs.triton.env.pythonRemoveDeps = [
    "torch"
  ];

  pip.drvs.torch.env.autoPatchelfIgnoreMissingDeps = ["libcuda.so.1"];

  pip.drvs.torchvision = {
    mkDerivation.dontStrip = true;
  };

  pip.drvs.pypatchmatch = {
    buildPythonPackage.pythonImportsCheck = ["patchmatch"];
  };

  pip.drvs.basicsr = {
    mkDerivation = {
      # basicsr needs some large python packages during build time only.
      # The exact versions don't matter much, so we just take those from nixpkgs
      nativeBuildInputs = [
        config.pip.drvs.cython.public
        config.pip.drvs.pip.public
      ];
      propagatedBuildInputs = [
        config.pip.drvs.tensorboard-data-server.public
      ];
      dontStrip = true;
      doCheck = false;
    };
    buildPythonPackage = {
      # Installing the dependencies causes to may issues for this package.
      # It's not important to fix it since all of the required dependencies
      # are installed at the top-level anyways.
      pipInstallFlags = [
        "--no-deps"
      ];
      # ...giving up on pythonRemoveDeps. It doesn't seem to work, let's just
      # ignore collisions for this package.
      catchConflicts = false;
    };
  };
}
