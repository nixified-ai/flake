{
  writeShellApplication,
}:
writeShellApplication {
  text = builtins.readFile ./github-get-default-branch.sh;
  name = "github-get-default-branch";
  derivationArgs = {
    preferLocalBuild = true;
    allowSubstitutes = false;
  };
}
