{
  pkgs,
  ...
}:
{
  pname = "ComfyUI_Comfyroll_CustomNodes";

  # Patch hard-coded paths and remove force library builds
  #/usr/share/fonts/truetype
  postPatch = ''
    substituteInPlace nodes/nodes_graphics_text.py \
      --replace 'font_dir = "/usr/share/fonts/truetype"' 'font_dir = "${pkgs.dejavu_fonts}/share/fonts/truetype"'
  '';
}
