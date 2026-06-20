{
  writeShellApplication,
  comfyui-nodes-npins,
}:
writeShellApplication {
  text = builtins.readFile ./add-comfyui-node.sh;
  name = "add-comfyui-node";
  runtimeInputs = [ comfyui-nodes-npins ];
  derivationArgs = {
    preferLocalBuild = true;
    allowSubstitutes = false;
  };
}
