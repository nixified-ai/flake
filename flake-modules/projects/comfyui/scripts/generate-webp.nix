{
  pkgs ? import <nixpkgs> { },
}:

pkgs.stdenv.mkDerivation {
  name = "test-animated-webp";
  buildInputs = [ pkgs.imagemagick ];
  phases = [
    "buildPhase"
    "installPhase"
  ];
  buildPhase = ''
    convert -size 512x512 xc:black black.png
    convert -size 512x512 xc:white white.png
    convert -size 512x512 xc:red red.png
    convert -delay 100 -loop 0 black.png white.png red.png animated.webp
  '';
  installPhase = ''
    mkdir -p $out
    cp animated.webp $out/animated.webp
  '';
}
