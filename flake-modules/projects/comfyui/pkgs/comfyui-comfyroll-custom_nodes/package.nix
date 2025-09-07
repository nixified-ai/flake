{
  pkgs,
  comfyuiPackages,
  fetchFromGitHub,
  ...
}:
comfyuiPackages.comfyui.mkComfyUICustomNode {
  pname = "ComfyUI_Comfyroll_CustomNodes";
  version = "d78b780";

  src = fetchFromGitHub {
    owner = "Suzie1";
    repo = "ComfyUI_Comfyroll_CustomNodes";
    rev = "d78b780ae43fcf8c6b7c6505e6ffb4584281ceca";
    hash = "sha256-+qhDJ9hawSEg9AGBz8w+UzohMFhgZDOzvenw8xVVyPc=";
  };

  # Patch hard-coded paths and remove force library builds
  #/usr/share/fonts/truetype
  postPatch = ''
    substituteInPlace nodes/nodes_graphics_text.py \
      --replace 'font_dir = "/usr/share/fonts/truetype"' 'font_dir = "${pkgs.dejavu_fonts}/share/fonts/truetype"'
  '';
}
