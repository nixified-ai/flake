{
  writeShellApplication,
  npins,
  jq,
  nix,
  git,
}:
writeShellApplication {
  text = builtins.readFile ./sync-manager-nodes.sh;
  name = "sync-manager-nodes";
  runtimeInputs = [
    npins
    jq
    nix
    git
  ];
  derivationArgs = {
    preferLocalBuild = true;
    allowSubstitutes = false;
  };
}
