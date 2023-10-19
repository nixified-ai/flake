{ lib
, buildPythonPackage
, fetchPypi
, hatch-fancy-pypi-readme
, hatch-requirements-txt
, hatchling
, fsspec
, httpx
, huggingface-hub
, packaging
, requests
, typing-extensions
, websockets
}:

buildPythonPackage rec {
  pname = "gradio-client";
  version = "0.2.5";
  format = "pyproject";

  src = fetchPypi {
    pname = "gradio_client";
    inherit version;
    hash = "sha256-GiTdegmXbbcP0yzbVRK297FcGghPMQtfazAhyXlNkKQ=";
  };

  nativeBuildInputs = [
    hatch-fancy-pypi-readme
    hatch-requirements-txt
    hatchling
  ];

  propagatedBuildInputs = [
    fsspec
    httpx
    huggingface-hub
    packaging
    requests
    typing-extensions
    websockets
  ];

  pythonImportsCheck = [ "gradio_client" ];

  meta = with lib; {
    description = "Python library for easily interacting with trained machine learning models";
    homepage = "https://github.com/gradio-app/gradio";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
