{
  lib,
  stdenv,
}:
{
  postPatch = ''
    substituteInPlace __init__.py \
      --replace-fail "result = filecmp.dircmp(javascript_folder, extentions_folder)" "result = None" \
      --replace-fail "if result.left_only or result.diff_files:" "if False:"
  '';
}
