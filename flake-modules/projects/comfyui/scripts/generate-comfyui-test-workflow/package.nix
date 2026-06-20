{ python3Packages, ... }:

python3Packages.buildPythonApplication {
  pname = "generate-comfyui-test-workflow";
  version = "1.0.0";
  format = "other";
  src = ./.;

  installPhase = ''
    install -D -m755 generate-comfyui-test-workflow.py $out/bin/generate-comfyui-test-workflow
    # Patch sources path so it uses the store source
    sed -i 's|sources_path = "./sources.json"|sources_path = "/build/sources.json"|g' $out/bin/generate-comfyui-test-workflow
  '';
}
