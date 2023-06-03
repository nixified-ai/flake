{ stdenv
, lib
, fetchurl
}:

stdenv.mkDerivation rec {
  pname = "liblzf";
  version = "3.6";

  src = fetchurl {
    url = "http://dist.schmorp.de/liblzf/liblzf-${version}.tar.gz";
    sha256 = "sha256-nF3gH3ucyuQMP2GdJqer7JmGwGw20mDBec7dBLiftGo=";
  };
}
