{ stdenv
, fetchurl
, lib
, unzip
, cmake
, gmp
, mpfr
, eigen2
, pkg-config
, embree
, libGL
, glfw
, boost
, tetgen
, cgal
, catch2
}:

stdenv.mkDerivation rec {
  pname = "libigl";
  version = "2.4.0";

  src = fetchurl {
    url = "https://www.meshlab.net/data/libs/libigl-${version}.zip";
    sha256 = "sha256-sg2AyaP6fQxrw63uWORPDNscu0kijfbWf53b/AjuFAM=";
  };

  cmakeFlags = [
    "-DFETCHCONTENT_FULLY_DISCONNECTED=ON"
  ];

  nativeBuildInputs = [ unzip cmake gmp pkg-config catch2 ];

  buildInputs = [ mpfr eigen2 embree libGL glfw boost tetgen cgal catch2 ];
}
