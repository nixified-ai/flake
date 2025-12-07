{
  lib,
  npins,
  nix,
  writeShellApplication,
}:
writeShellApplication {
  text = ''exec ${lib.getExe npins} -d flake-modules/projects/comfyui/npins "''${@}"'';
  name = "comfyui-npins";
  runtimeInputs = [ nix ];
  derivationArgs = {
    preferLocalBuild = true;
    allowSubstitutes = false;
  };
}
