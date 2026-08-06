{ python3Packages, ... }:

python3Packages.buildPythonApplication {
  pname = "generate-comfyui-test-workflow";
  version = "1.0.0";
  format = "other";
  src = ./.;

  installPhase = ''
    install -D -m755 generate-comfyui-test-workflow.py $out/bin/generate-comfyui-test-workflow
  '';
}
