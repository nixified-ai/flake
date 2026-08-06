{
  lib,
  stdenv,
}:
{
  preInstall = ''
    # Move the contents of comfyui_manager to the root so the default installPhase picks them up
    mv comfyui_manager/* .
  '';
}
