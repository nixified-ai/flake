{ aipython3
, callPackage
, src
}:
let
  abseil-onnx = callPackage ./packages/abseil-onnx { };
  microsoft-gsl = callPackage ./packages/microsoft-gsl { };
  onnx-custom = callPackage ./packages/onnx { inherit aipython3; };
  onnxruntime = callPackage ./packages/onnxruntime { inherit aipython3 microsoft-gsl onnx-custom; abseil-cpp = abseil-onnx; };
  onnxruntime-pyt = callPackage ./packages/onnxruntime-python
    { inherit aipython3 onnxruntime; };
in

aipython3.buildPythonPackage {
  pname = "rembg";
  format = "pyproject";
  version = "2.0.50";
  inherit src;
  propagatedBuildInputs = with aipython3; [
    numpy
    onnxruntime-pyt
    opencv4
    pillow
    pooch
    pymatting
    scikit-image
    scipy
    setuptools
    tqdm

    # {{{ cli deps
    aiohttp
    asyncer
    click
    fastapi
    filetype
    gradio
    python-multipart
    uvicorn
    watchdog
    # }}}
  ];
  nativeBuildInputs = [ aipython3.pythonRelaxDepsHook ];
  pythonRemoveDeps = [ "clip" "pyreadline3" "flaskwebgui" "opencv-python" ];
  pythonRelaxDeps = [ "dnspython" "protobuf" "flask" "flask-socketio" "pytorch-lightning" ];
  postFixup = ''
    chmod +x $out/bin/*
    wrapPythonPrograms
  '';
  doCheck = false;
  meta = {
    description = "tool to remove image backgrounds";
    homepage = "https://github.com/danielgatis/rembg/";
    mainProgram = "rembg";
  };
}
