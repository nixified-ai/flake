{
  python3Packages,
  gccStdenv,
}:
let
  pyloudnorm = python3Packages.callPackage ../../../../packages/pyloudnorm/default.nix { };
  sageattention = python3Packages.callPackage ../../../../packages/sageattention/default.nix { };
in
{
  pname = "comfyui-kijai-wan-video-wrapper";
  pyproject = false;
  propagatedBuildInputs = with python3Packages; [
    ftfy
    accelerate
    einops
    diffusers
    peft
    sentencepiece
    protobuf
    pyloudnorm
    gguf
    sageattention
    gccStdenv.cc
  ];
  dontUseNinjaBuild = true;
}
