{
  lib,
  fetchPypi,
  buildPythonPackage,
  setuptools,
  wheel,
  pydantic-settings,
  ...
}:
buildPythonPackage rec {
  pname = "comfyui-embedded-docs";
  version = "0.2.6";

  src = fetchPypi {
    inherit version;
    pname = "comfyui_embedded_docs";
    hash = "sha256-ild/PuIWvo3NbAjpZYxvJX/7np6B9A8NNt6bSZJJdWo=";
  };
  pyproject = true;

  nativeBuildInputs = [setuptools wheel];

  propagatedBuildInputs = [
    pydantic-settings
  ];

  meta = with lib; {
    description = " ComfyUI help pages";
    homepage = "https://github.com/Comfy-Org/embedded-docs";
    license = licenses.gpl3Only;
    platforms = platforms.all;
  };
}
