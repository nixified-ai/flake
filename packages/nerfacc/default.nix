{ buildPythonPackage
, fetchPypi
, lib
, torch
, which
, hip
, rocthrust
, rocrand
, hipsparse
, hipblas
, rocblas
, cudaPackages
, gcc11Stdenv
, runCommand
, ninja
, rich
, typing-extensions
}:

let
  isRocm = torch.rocmSupport or false;
  package = buildPythonPackage rec {
    pname = "nerfacc";
    version = "0.5.2";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-kEl3g7G4Rt62x/BwRSDqezSCo2PzouI+M7326LzmvaU=";
    };

    preConfigure = ''
      export HOME=$(mktemp -d)
    '';

    enableParallelBuilding = true;


    TORCH_CUDA_ARCH_LIST = "3.5;5.2;6.0;6.1;7.0+PTX";

    nativeBuildInputs = [ which ninja ]
      ++ (if isRocm
        then [
          hip
        ] else [
          cudaPackages.cudatoolkit 
        ]
      );

    buildInputs = [ ]
      ++ (if isRocm
      then [
        rocthrust
        rocrand
        hipsparse
        (runCommand "rocblas-link" {} "mkdir $out -p; ln -s ${rocblas}/include/rocblas $out/include")
      ]
      else [
        cudaPackages.cuda_cudart
      ])
    ;

    propagatedBuildInputs = [ torch rich typing-extensions ];
  };
in package.overrideDerivation (old: {
  stdenv = gcc11Stdenv;
})


