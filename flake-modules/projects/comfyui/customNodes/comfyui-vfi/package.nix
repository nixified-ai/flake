{ pkgs, ... }:
{
  dontUseNinjaBuild = true;
  propagatedBuildInputs = with pkgs.python3Packages; [
    torch
    torchvision
    numpy
    requests
  ];
}
