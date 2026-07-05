{ writeShellApplication }:
writeShellApplication {
  name = "run-container-tests";
  text = builtins.readFile ./run-container-tests.sh;
  derivationArgs = {
    preferLocalBuild = true;
    allowSubstitutes = false;
  };
}
