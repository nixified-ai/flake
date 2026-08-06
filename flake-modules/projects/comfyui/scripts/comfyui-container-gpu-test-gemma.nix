{
  writeShellApplication,
}:
writeShellApplication {
  name = "comfyui-container-gpu-test-gemma";
  text = builtins.readFile ./comfyui-container-gpu-test-gemma.sh;
  derivationArgs = {
    preferLocalBuild = true;
    allowSubstitutes = false;
  };
}
