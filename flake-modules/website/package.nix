{ lib, pandoc, stdenvNoCC }:

lib.fix (self: stdenvNoCC.mkDerivation {
  pname = "nixified-ai-website";
  version = "1.0.0";

  src = ./src;

  nativeBuildInputs = [
    pandoc
  ];

  buildCommand = ''
    unpackPhase
    cd $sourceRoot

    pandoc \
      --css=./styles.css \
      -H header.html \
      -V pagetitle='Nixified AI' \
      -s index.md \
      -o index.html

    webroot=$out/share/www/nixified.ai
    mkdir -p $webroot
    cp -v index.html *.css *.png CNAME $webroot
  '';

  passthru.webroot = "${self}/share/www/nixified.ai";
})
