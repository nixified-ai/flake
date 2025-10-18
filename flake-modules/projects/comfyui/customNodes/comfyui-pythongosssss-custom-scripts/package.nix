{
  python3Packages,
}:
let
  custom-scripts-autocomplete-text = (
    builtins.fetchurl {
      url = "https://gist.githubusercontent.com/pythongosssss/1d3efa6050356a08cea975183088159a/raw/a18fb2f94f9156cf4476b0c24a09544d6c0baec6/danbooru-tags.txt";
      sha256 = "15xmm538v0mjshncglpbkw2xdl4cs6y0faz94vfba70qq87plz4p";
    }
  );
in
{
  pname = "comfyui-pythongosssss-custom-scripts";
  patches = [ ./skip-install-js.patch ];

  preInstall = ''
    ln -s pysssss.default.json pysssss.json
    mkdir -p web-extensions
    ln -s ${custom-scripts-autocomplete-text} user/autocomplete.txt
    ln -s ../web/js web-extensions/pysssss
    ls -al web-extensions
  '';
}
