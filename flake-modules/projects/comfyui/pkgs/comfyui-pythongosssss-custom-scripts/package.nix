{ comfyuiPackages,
  python3Packages,
  fetchFromGitHub
}:
let
  custom-scripts-autocomplete-text = (builtins.fetchurl {
    url = "https://gist.githubusercontent.com/pythongosssss/1d3efa6050356a08cea975183088159a/raw/a18fb2f94f9156cf4476b0c24a09544d6c0baec6/danbooru-tags.txt";
    sha256 = "15xmm538v0mjshncglpbkw2xdl4cs6y0faz94vfba70qq87plz4p";
  });
in
comfyuiPackages.comfyui.mkComfyUICustomNode {
  pname = "comfyui-pythongosssss-custom-scripts";
  version = "unstable-2025-04-30";
  src = fetchFromGitHub {
    owner = "pythongosssss";
    repo = "ComfyUI-Custom-Scripts";
    rev = "aac13aa7ce35b07d43633c3bbe654a38c00d74f5";
    hash = "sha256-Qgx+/SrXrkHNI1rH+9O2CmN7NwrQi7CvPAFTdacZ2C0=";
  };
  patches = [ ./skip-install-js.patch ];

  preInstall = ''
    ln -s pysssss.default.json pysssss.json
    mkdir -p web-extensions
    ln -s ${custom-scripts-autocomplete-text} user/autocomplete.txt
    ln -s ../web/js web-extensions/pysssss
    ls -al web-extensions
  '';
}
