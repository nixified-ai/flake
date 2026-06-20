{
  writeShellApplication,
  comfyui-nodes-npins,
  github-get-default-branch,
  gitlab-get-default-branch,
}:
writeShellApplication {
  text = builtins.readFile ./add-comfyui-node.sh;
  name = "add-comfyui-node";
  runtimeInputs = [
    comfyui-nodes-npins
    github-get-default-branch
    gitlab-get-default-branch
  ];
  derivationArgs = {
    preferLocalBuild = true;
    allowSubstitutes = false;
  };
}
