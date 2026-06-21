{
  python3Packages,
}:
{
  pname = "comfyui-inspire-pack";
  pyproject = false;
  dontUseNinjaBuild = true;
  propagatedBuildInputs = with python3Packages; [
    matplotlib
    cachetools
    numpy
    webcolors
    opencv4
    pyyaml
    safetensors
    einops
    aiohttp
  ];
}
