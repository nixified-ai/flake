{
  lib,
  npins,
  nix,
  writeShellApplication,
}:
writeShellApplication {
  text = ''exec ${lib.getExe npins} -d flake-modules/projects/comfyui/manager-npins "''${@}"'';
  name = "comfyui-manager-nodes-npins";
  runtimeInputs = [ nix ];
  derivationArgs = {
    preferLocalBuild = true;
    allowSubstitutes = false;
  };
}
