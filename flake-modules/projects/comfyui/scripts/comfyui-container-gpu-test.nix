{
  writeShellApplication,
}:
writeShellApplication {
  name = "comfyui-container-gpu-test";
  text = builtins.readFile ./comfyui-container-gpu-test.sh;
  derivationArgs = {
    preferLocalBuild = true;
    allowSubstitutes = false;
  };
}
