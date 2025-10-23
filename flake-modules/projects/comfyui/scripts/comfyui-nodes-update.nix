{
  lib,
  comfyui-nodes-npins,
  writeShellApplication,
}:
writeShellApplication {
  text = "exec ${lib.getExe comfyui-nodes-npins} update";
  name = "comfyui-nodes-update";
  derivationArgs = {
    preferLocalBuild = true;
    allowSubstitutes = false;
  };
}
