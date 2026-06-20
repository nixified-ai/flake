{
  writeShellApplication,
  curl,
  jq,
}:
writeShellApplication {
  text = builtins.readFile ./gitlab-get-default-branch.sh;
  name = "gitlab-get-default-branch";
  runtimeInputs = [
    curl
    jq
  ];
  derivationArgs = {
    preferLocalBuild = true;
    allowSubstitutes = false;
  };
}
