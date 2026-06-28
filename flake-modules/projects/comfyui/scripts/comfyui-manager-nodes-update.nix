{
  lib,
  comfyui-manager-nodes-npins,
  writeShellApplication,
}:
writeShellApplication {
  text = "exec ${lib.getExe comfyui-manager-nodes-npins} update";
  name = "comfyui-manager-nodes-update";
  derivationArgs = {
    preferLocalBuild = true;
    allowSubstitutes = false;
  };
}
