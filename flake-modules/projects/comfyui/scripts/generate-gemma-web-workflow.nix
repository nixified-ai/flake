{
  writeShellApplication,
}:
writeShellApplication {
  name = "generate-gemma-web-workflow";
  text = builtins.readFile ./generate-gemma-web-workflow.sh;
}
