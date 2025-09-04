{
  lib,
  fetchFromGitHub,
  python,
  buildPythonPackage,
  setuptools,
  wheel,
  pydantic-settings,
  pnpm,
  stdenv,
  nodejs_24,
  ...
}: let
  version = "1.26.7";
  pname = "comfyui-frontend";

  src = fetchFromGitHub {
    owner = "Comfy-Org";
    repo = "ComfyUI_frontend";
    rev = "v${version}";
    hash = "sha256-2mnLsTPE6K+6SVV3WhnwtmOcRAjAoRDT1i3VEi8PCd8=";
  };

  static = stdenv.mkDerivation {
    inherit pname src version;
    nativeBuildInputs = [
      nodejs_24
      pnpm.configHook
    ];

    pnpmDeps = pnpm.fetchDeps {
      inherit pname version src;
      fetcherVersion = 2;
      hash = "sha256-GAXA+0Uo2Sq6FEruTe53FtI5xOXR2KL+1PYZ9jEJ+ZE=";
      # hash = "sha256-wyKtNflcaVt/1zHvdR9x1O6/c3hVqDgrHVzJ/Hu/FXc=";
    };

    buildPhase = ''
      runHook preBuild
      pnpm build
      runHook postBuild
    '';

    postInstall = ''
      cp -r ./dist $out/
    '';
  };
in
  buildPythonPackage {
    pname = "comfyui-frontend";
    version = version;

    src = src + /comfyui_frontend_package;

    pyproject = true;

    COMFYUI_FRONTEND_VERSION = "${version}";

    nativeBuildInputs = [setuptools wheel];

    propagatedBuildInputs = [
      pydantic-settings
    ];

    postInstall = ''
      mkdir -p $out/lib/${python.libPrefix}/site-packages/comfyui_frontend_package/static
      cp -r ${static}/* $out/lib/${python.libPrefix}/site-packages/comfyui_frontend_package/static
    '';

    meta = with lib; {
      description = "Official front-end implementation of ComfyUI";
      homepage = "https://github.com/Comfy-Org/ComfyUI_frontend";
      license = licenses.gpl3Only;
      platforms = platforms.all;
    };
  }
