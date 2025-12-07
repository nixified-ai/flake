{
  lib,
  npins,
  nix,
  writeShellApplication,
}:
writeShellApplication {
  text = ''exec ${lib.getExe npins} -d flake-modules/projects/comfyui/customNodes-npins "''${@}"'';
  name = "comfyui-nodes-npins";
  runtimeInputs = [ nix ];
  derivationArgs = {
    preferLocalBuild = true;
    allowSubstitutes = false;
  };
}
