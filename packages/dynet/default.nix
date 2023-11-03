{ lib
, stdenv
, fetchgit
, cmake
, python3Packages
, eigen
, cudaPackages
}:

stdenv.mkDerivation rec {
  pname = "dynet";
  version = "master-2023-11-03";

  src = fetchgit {
    url = "https://github.com/clab/dynet";
    rev = "c418b09dfb08be8c797c1403911ddfe0d9f5df77";
    sha256 = "12f0qb3iw24czynwh7zzi1hxzrjr8x78n0hpa7hnjya06mlwapmp";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ 
    eigen
    python3Packages.python 
    python3Packages.setuptools 
    cudaPackages.cudatoolkit
  ];

  cmakeFlags = [
    "-DENABLE_CPP_EXAMPLES=OFF"
    "-DBACKEND=cuda"
  ];

  preConfigure = ''
    export CUDNN_ROOT=${cudaPackages.cudatoolkit}/lib
  '';

  meta = with lib; {
    description = "Dynamic Neural Network Toolkit";
    homepage = "https://github.com/clab/dynet";
    license = licenses.asl20;  # Apache 2.0 License
    maintainers = with maintainers; [ ];
  };
}
