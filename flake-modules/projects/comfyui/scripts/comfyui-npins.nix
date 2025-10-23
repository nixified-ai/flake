{
  lib,
  npins,
  writeShellApplication,
}:
writeShellApplication {
  text = ''exec ${lib.getExe npins} -d flake-modules/projects/comfyui/npins "''${@}"'';
  name = "comfyui-npins";
  derivationArgs = {
    preferLocalBuild = true;
    allowSubstitutes = false;
  };
}
