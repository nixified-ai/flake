{ stdenv
, lib
, fetchzip
, tinyxml
, pkg-config
, gtk2
, glew
, freeglut
, libGLU
}:

stdenv.mkDerivation rec {
  pname = "OpenCTM";
  version = "1.0.3";

  prePatch = ''
    echo 'include Makefile.linux' > Makefile
    substituteInPlace Makefile.linux \
      --replace /usr/local $out \
      --replace /usr $out
  '';

  preInstall = ''
    mkdir -p $out/{bin,lib,include,share/man/man1}
  '';

  NIX_LDFLAGS = [ "-lGL" "-lGLU"];
  NIX_CFLAGS_COMPILE = [ "-Wformat" "-Wl,--copy-dt-needed-entries" ];

  buildInputs = [ gtk2 tinyxml freeglut libGLU ];

  nativeBuildInputs = [ pkg-config ];

  src = fetchzip {
    url = "https://www.meshlab.net/data/libs/OpenCTM-${version}-src.zip";
    sha256 = "sha256-zG3GxSurEuoSU8AoFFfguCgXyZJ2CCdRlsFeZH7/YW8=";
  };
}
