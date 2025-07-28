{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  wheel,
  python,
  ...
}:
buildPythonPackage rec {
  pname = "comfyui-workflow-templates";
  version = "0.1.75";

  src = fetchFromGitHub {
    owner = "Comfy-Org";
    repo = "workflow_templates";
    rev = "v${version}";
    hash = "sha256-bRoNTH89DvxBWMOYaWdFfftFBlUXnMm8fkFTyOxxIvc=";
  };
  pyproject = true;

  nativeBuildInputs = [setuptools wheel];

  postInstall = ''
    mkdir -p $out/lib/${python.libPrefix}/site-packages/comfyui_workflow_templates/templates
    cp -r ${src}/templates/* $out/lib/${python.libPrefix}/site-packages/comfyui_workflow_templates/templates
  '';

  meta = with lib; {
    description = "ComfyUI template workflows";
    homepage = "https://github.com/Comfy-Org/workflow_templates";
    license = licenses.gpl3Only;
    platforms = platforms.all;
  };
}
