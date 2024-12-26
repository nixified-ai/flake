{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "ai-toolkit";
  version = "unstable-2024-12-15";

  src = fetchFromGitHub {
    owner = "ostris";
    repo = "ai-toolkit";
    rev = "8ef07a9c3662351328407d9249a5418639dd3052";
    hash = "sha256-pPEc+LQ9wUVX5it5nr9qHbcpTTIlg+asRE2rM2W8fBw=";
    fetchSubmodules = true;
  };

  meta = {
    description = "Various AI scripts. Mostly Stable Diffusion stuff";
    homepage = "https://github.com/ostris/ai-toolkit";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "ai-toolkit";
    platforms = lib.platforms.all;
  };
}
