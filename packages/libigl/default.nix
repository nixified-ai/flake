{ buildPythonPackage
, fetchzip
, fetchgit
, lib
, unzip
, cmake
, gmp
, mpfr
, eigen
, pkg-config
, embree
, libGL
, glfw
, boost
, cgal
, catch2
, glad
, ispc
, tbb
, imgui
, tinyxml2
, libpng
, xorg
, stb
}:

let
  getFetchContent = { cmakeFile, hashes ? {} }: let
    inherit (builtins) readFile split filter match typeOf head tail foldl';
    inherit (lib) pipe flatten;

    data = pipe (readFile cmakeFile) [
      (split "\n")
      (filter (x: typeOf x == "string"))
      (flatten)
      (map (match " *(.*GIT.*) *"))
      (flatten)
      (filter (x: x != null))
      (map (x: let line = lib.pipe x [
        (split " ")
        (filter (v: typeOf v == "string" && v != ""))
      ]; in { "${head line}" = "${head (tail line)}";}))
      (foldl' (x: y: x // y) {})
    ];

    rev = builtins.replaceStrings [ "tags/" ] [ "" ] data.GIT_TAG;
  in fetchgit {
    url = "${data.GIT_REPOSITORY}";
    inherit rev;
    sha256 = hashes.${rev} or (builtins.trace "getFetchContent: fallback hash for '${data.GIT_REPOSITORY}' '${data.GIT_TAG}'" lib.fakeSha256);
  };

  version = "2.4.0";
  src = fetchzip {
    url = "https://www.meshlab.net/data/libs/libigl-${version}.zip";
    sha256 = "sha256-HRD854Y/F2jwVKEvewbYYy/rgf3tmEb8ZFCtbtG9lmI=";
  };

  inputs = {
    embree = {
      "v3.13.3" = "sha256-g6BsXMNUvx17hgAq0PewtBLgtWqpp03M0k6vWNapDKs=";
    };
    tinyxml2 = {
      "d175e9de0be0d4db75d0a8cf065599a435a87eb6" = "sha256-g5D88Vl2EhtEp+jh5J0+T+P5hM7raM/41qh3Ud9Sg6o=";
    };
    stb = {
        "f67165c2bb2af3060ecae7d20d6f731173485ad0" = "sha256-b/T+8omHlUVmA6a+66FbgH++iXy4cZJD3Q5HTXApGa0=";
    };
    libigl_imgui_fonts = {
        "7e1053e750b0f4c129b046f4e455243cb7f804f3" = "sha256-3+rscFLD0OvsjRJIDRvENSf4Vorons6QDV6pXBVCYRM=";
    };
    catch2 = {
        "v2.13.8" = "sha256-jOA2TxDgaJUJ2Jn7dVGZUbjmphTDuVZahzSaxfJpRqE=";
    };
    eigen = {
        "3.3.7" = "sha256-oXJ4V5rakL9EPtQF0Geptl0HMR8700FdSrOB09DbbMQ=";
    };
    glad = {
        "09b4969c56779f7ddf8e6176ec1873184aec890f" = "sha256-k6s8Ct3FGPq43+5bAvq56bGrqPsys7P7M5f6EcrRmWc=";
    };
    glfw = {
        "3327050ca66ad34426a82c217c2d60ced61526b7" = "sha256-XBVxtkL29WqQooM2+wkorjjWIpXj0g3X8rkGhSiNoxI=";
    };
    imguizmo = {
        "a23567269f6617342bcc112394bdad937b54b2d7" = "sha256-l5BOeBkJlX6VAGNDM+Ouc8YnwooRqzZbcmRFyeO/ZCU=";
    };
    imgui = {
        "v1.85" = "sha256-HQsGlsvmf3ikqhGnJHf/d6SRCY/QDeW7XUTwXQH/JYE=";
    };
    libigl_tests_data = {
        "name" = "libigl_tests_tata";
        "19cedf96d70702d8b3a83eb27934780c542356fe" = "sha256-IhLlfe89utbIks/z1Re1dbgUDqpX1iqJIryTw3umr/M=";
    };
  };

  inputsCMakeVars = lib.pipe inputs [
    (builtins.attrNames)
    (map (dir: "-DFETCHCONTENT_SOURCE_DIR_${lib.toUpper (inputs.${dir}.name or dir)}=../.${dir}"))
  ];

  inputsDerivations = builtins.mapAttrs (k: v: getFetchContent {
    cmakeFile = "${src}/cmake/recipes/external/${k}.cmake";
    hashes = inputs.${k};
  }) inputs;

  inputsPatchPhase = lib.pipe inputsDerivations [
    (builtins.attrNames)
    (map (k: "cp -r ${inputsDerivations.${k}} -r .${k}; chmod +w .${k} -R"))
    (builtins.concatStringsSep "\n")
  ];

in

buildPythonPackage rec {
  pname = "libigl";

  inherit src version;

  format = "other";

  cmakeSuffix = ''
    # include(FindPkgConfig)
    # find_package(eigen REQUIRED eigen-populate)
    # find_package(glfw3 REQUIRED glfw)
    # find_package(glad REQUIRED)
  '';

  prePatch = ''
    ${inputsPatchPhase}

    echo "$cmakeSuffix" >> CMakeLists.txt
  '';

  cmakeFlags = inputsCMakeVars ++ [
    # "-DFETCHCONTENT_FULLY_DISCONNECTED=ON"
    "-DLIBGL_EMBREE=OFF"
    "-DFETCHCONTENT_TRY_FIND_PACKAGE_MODE=ALWAYS"
    "-DLIBIGL_BUILD_TUTORIALS=OFF"
    "-DLIBIGL_COPYLEFT_CGAL=OFF"
    "-DLIBIGL_COPYLEFT_COMISO=OFF"
    "-DLIBIGL_COPYLEFT_CORE=OFF"
    "-DLIBIGL_COPYLEFT_CORK=OFF"
    "-DLIBIGL_COPYLEFT_TETGEN=OFF"
    "-DLIBIGL_PREDICATES=OFF"
    "-DLIBIGL_RESTRICTED_MATLAB=OFF"
    "-DLIBIGL_RESTRICTED_MOSEK=OFF"
    "-DLIBIGL_RESTRICTED_TRIANGLE=OFF"
    "-DTBB_DIR=${tbb.src}"
    # "-DFETCHCONTENT_SOURCE_DIR_EMBREE=../.embree" # embree needs to be in a mutable location
    # "-DFETCHCONTENT_SOURCE_DIR_TINYXML2=${getFetchContent {
    #   cmakeFile = "${src}/cmake/recipes/external/tinyxml2.cmake";
    #   hashes = {
    #     "d175e9de0be0d4db75d0a8cf065599a435a87eb6" = "sha256-g5D88Vl2EhtEp+jh5J0+T+P5hM7raM/41qh3Ud9Sg6o=";
    #   };
    # }}"
    # "-DFETCHCONTENT_SOURCE_DIR_STB=${getFetchContent {
    #   cmakeFile = "${src}/cmake/recipes/external/stb.cmake";
    #   hashes = {
    #     "f67165c2bb2af3060ecae7d20d6f731173485ad0" = "sha256-b/T+8omHlUVmA6a+66FbgH++iXy4cZJD3Q5HTXApGa0=";
    #   };
    # }}"
    # "-DFETCHCONTENT_SOURCE_DIR_LIBIGL_IMGUI_FONTS=${getFetchContent {
    #   cmakeFile = "${src}/cmake/recipes/external/libigl_imgui_fonts.cmake";
    #   hashes = {
    #     "7e1053e750b0f4c129b046f4e455243cb7f804f3" = "sha256-3+rscFLD0OvsjRJIDRvENSf4Vorons6QDV6pXBVCYRM=";
    #   };
    # }}"
    # "-DFETCHCONTENT_SOURCE_DIR_CATCH2=${getFetchContent {
    #   cmakeFile = "${src}/cmake/recipes/external/catch2.cmake";
    #   hashes = {
    #     "v2.13.8" = "sha256-jOA2TxDgaJUJ2Jn7dVGZUbjmphTDuVZahzSaxfJpRqE=";
    #   };
    # }}"
    # "-DFETCHCONTENT_SOURCE_DIR_EIGEN=${getFetchContent {
    #   cmakeFile = "${src}/cmake/recipes/external/eigen.cmake";
    #   hashes = {
    #     "3.3.7" = "sha256-oXJ4V5rakL9EPtQF0Geptl0HMR8700FdSrOB09DbbMQ=";
    #   };
    # }}"
    # "-DFETCHCONTENT_SOURCE_DIR_GLAD=${getFetchContent {
    #   cmakeFile = "${src}/cmake/recipes/external/glad.cmake";
    #   hashes = {
    #     "09b4969c56779f7ddf8e6176ec1873184aec890f" = "sha256-k6s8Ct3FGPq43+5bAvq56bGrqPsys7P7M5f6EcrRmWc=";
    #   };
    # }}"
    # "-DFETCHCONTENT_SOURCE_DIR_GLFW=${getFetchContent {
    #   cmakeFile = "${src}/cmake/recipes/external/glfw.cmake";
    #   hashes = {
    #     "3327050ca66ad34426a82c217c2d60ced61526b7" = "sha256-XBVxtkL29WqQooM2+wkorjjWIpXj0g3X8rkGhSiNoxI=";
    #   };
    # }}"
    # "-DFETCHCONTENT_SOURCE_DIR_IMGUIZMO=${getFetchContent {
    #   cmakeFile = "${src}/cmake/recipes/external/imguizmo.cmake";
    #   hashes = {
    #     "a23567269f6617342bcc112394bdad937b54b2d7" = "sha256-l5BOeBkJlX6VAGNDM+Ouc8YnwooRqzZbcmRFyeO/ZCU=";
    #   };
    # }}"
    # "-DFETCHCONTENT_SOURCE_DIR_IMGUI=${getFetchContent {
    #   cmakeFile = "${src}/cmake/recipes/external/imgui.cmake";
    #   hashes = {
    #     "v1.85" = "sha256-HQsGlsvmf3ikqhGnJHf/d6SRCY/QDeW7XUTwXQH/JYE=";
    #   };
    # }}"
    # "-DFETCHCONTENT_SOURCE_DIR_LIBIGL_TESTS_TATA=${getFetchContent {
    #     cmakeFile = "${src}/cmake/recipes/external/libigl_tests_data.cmake";
    #     hashes = {
    #       "19cedf96d70702d8b3a83eb27934780c542356fe" = "sha256-IhLlfe89utbIks/z1Re1dbgUDqpX1iqJIryTw3umr/M=";
    #     };
    # }}"
  ];

  nativeBuildInputs = [ unzip cmake gmp pkg-config ];

  buildInputs = [
    mpfr
    libGL
    libpng
    xorg.libX11
    xorg.libXrandr
    xorg.libXinerama
    xorg.libXcursor
    xorg.libXi
    stb
  ];
}
