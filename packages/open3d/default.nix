{ buildPythonPackage
, lib
, fetchFromGitHub
, cmake
, assimp
, boringssl
, cudaPackages
, curl
, eigen
, gitMinimal
, glfw
, glew
, ispc
, jsoncpp
, libcxx
, libcxxabi
, libjpeg
, libpng
, nanoflann
, nasm
, ninja
, pybind11
, torch
, vulkan-headers
, vulkan-loader
, xorg
, tinygltf
, tinyobjloader
, qhull
, fmt
, imgui
, python-lzf
, python
, fetchurl
, msgpack
, vtk
, tbb
, mkl
, tensorflow
, useOldCXXAbi
, gtest
, librealsense
, libsodium
, zeromq
, pkg-config
, zlib
, liblzf
}:

let
  isRocm = torch.rocmSupport or false;
in

buildPythonPackage rec {
  pname = "open3d";
  version = "0.17.0";

  format = "other";

  src = fetchFromGitHub {
    owner = "isl-org";
    repo = "Open3D";
    rev = "v${version}";
    sha256 = "sha256-dGdDnHch71O7wAbK8Sg+0uH0p99avUtrG/lFmpsx45Y=";
  };

  prePatch = ''
    substituteAllInPlace 3rdparty/uvatlas/uvatlas.cmake \
      --replace '${"$"}{INSTALL_DIR}/'
      # --replace '${"$"}{Open3D_INSTALL_LIB_DIR}/${"$"}{CMAKE_STATIC_LIBRARY_PREFIX}uvatlas' ""
    cat 3rdparty/uvatlas/uvatlas.cmake
  '';

  cmakeFlags = [
    "-DOPEN3D_VERSION=${version}"
    "-DCMAKE_ISPC_COMPILER=${ispc}/bin/ispc"
    "-DCPP_LIBRARY=${libcxx}/lib"
    "-DVULKAN_INCLUDE_DIR=${vulkan-headers}/include"
    "-Dmsgpack_DIR=${msgpack}"
    "-DTinyGLTF_DIR=${tinygltf}"
    "-Dvtk_DIR=${vtk}"
    # "-DBORINGSSL_ROOT_DIR=${boringssl}"
    # "-DImGui_LIBRARY=${imgui}/lib"
    # "-Dliblzf_DIR=${python-lzf}"
    # "-DTensorflow_CXX11_ABI=OFF"
    # "-DPytorch_CXX11_ABI=OFF"
    "-DBUILD_COMMON_CUDA_ARCHS=ON"
    "-DGLIBCXX_USE_CXX11_ABI=ON"
    "-DBUILD_SHARED_LIBS=ON"
    "-DUSE_SYSTEM_ASSIMP=ON"
    "-DUSE_SYSTEM_CURL=ON"
    "-DUSE_SYSTEM_EIGEN3=ON"
    "-DUSE_SYSTEM_FILAMENT=ON"
    "-DUSE_SYSTEM_FMT=ON"
    "-DUSE_SYSTEM_GLEW=ON"
    "-DUSE_SYSTEM_GLFW=ON"
    "-DUSE_SYSTEM_GOOGLETEST=ON"
    "-DUSE_SYSTEM_IMGUI=ON"
    "-DUSE_SYSTEM_JPEG=ON"
    "-DUSE_SYSTEM_JSONCPP=ON"
    "-DUSE_SYSTEM_LIBLZF=ON"
    "-DUSE_SYSTEM_MSGPACK=ON"
    "-DUSE_SYSTEM_NANOFLANN=ON"
    "-DUSE_SYSTEM_OPENSSL=ON"
    "-DUSE_SYSTEM_PNG=ON"
    "-DUSE_SYSTEM_PYBIND11=ON"
    "-DUSE_SYSTEM_QHULLCPP=ON"
    "-DUSE_SYSTEM_TBB=ON"
    "-DUSE_SYSTEM_TINYGLTF=ON"
    "-DUSE_SYSTEM_TINYOBJLOADER=ON"
    "-DUSE_SYSTEM_VTK=ON"
    "-DUSE_SYSTEM_ZEROMQ=ON"
    # "-DBUILD_TENSORFLOW_OPS=ON"
    # "-DBUILD_PYTORCH_OPS=ON"
    "-DBUILD_JUPYTER_EXTENSION=ON"
    # "-DBUNDLE_OPEN3D_ML=ON"
    # "-GNinja"
  ]
    ++ (if isRocm
    then [ ]
    else [ "-DBUILD_CUDA_MODULE=ON" ]
    );

    downloadDepsHook = let
      deps = {
        "3rdparty_downloads/mesa/mesa_libGL_22.1.4.tar.bz2" = fetchurl {
          url = "https://github.com/isl-org/open3d_downloads/releases/download/mesa-libgl/mesa_libGL_22.1.4.tar.bz2";
          sha256 = "sha256-VzK/tw6PzHRwGIILyP0xzRhn665aoJuvZUgrQsE01Fo=";
        };
        "3rdparty_downloads/open3d_sphinx_theme/c71d2728eb5afd1aeeb20dc27a5a0d42bb402d83.tar.gz" = fetchurl {
          url = "https://github.com/isl-org/open3d_sphinx_theme/archive/c71d2728eb5afd1aeeb20dc27a5a0d42bb402d83.tar.gz";
          sha256 = "sha256-mK+Lf9t1p0KAthh9u1jqYB25eNTz+JVtPYfFnCB4b3M=";
        };
      };
      downloadElement = name: value: ''
        mkdir -p $(dirname ${name})
        ln -s ${value} ${name}
      '';
      downloadCommands = builtins.mapAttrs (downloadElement) deps;
    in builtins.concatStringsSep "\n" (builtins.attrValues downloadCommands);

    preConfigure = ''
      runHook downloadDepsHook
    '';


    buildInputs = [
      assimp
      curl
      eigen
      glfw
      glew
      jsoncpp
      libcxx
      libcxxabi
      libsodium
      libjpeg
      nanoflann
      pybind11
      vulkan-loader
      tinygltf
      tinyobjloader
      qhull
      fmt
      imgui
      liblzf
      python
      msgpack
      vtk
      tbb
      mkl
      tensorflow
      torch
      librealsense
      zeromq
      zlib
      libpng
    ]
    ++ (if isRocm
      then []
      else [
        cudaPackages.cudatoolkit
        cudaPackages.cuda_cudart
        cudaPackages.cudnn
      ]
    );

    nativeBuildInputs = [
      cmake
      # ninja
      useOldCXXAbi
      gtest
      pkg-config
    ];
}
