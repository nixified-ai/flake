{
  lib,
  comfyui-npins,
  writeShellApplication,
}:
writeShellApplication {
  text = "exec ${lib.getExe comfyui-npins} update";
  name = "comfyui-update";
  derivationArgs = {
    preferLocalBuild = true;
    allowSubstitutes = false;
  };
}
