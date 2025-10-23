{
  lib,
  npins,
  writeShellApplication,
}:
writeShellApplication {
  text = ''exec ${lib.getExe npins} -d flake-modules/projects/comfyui/customNodes-npins "''${@}"'';
  name = "comfyui-nodes-npins";
  derivationArgs = {
    preferLocalBuild = true;
    allowSubstitutes = false;
  };
}
