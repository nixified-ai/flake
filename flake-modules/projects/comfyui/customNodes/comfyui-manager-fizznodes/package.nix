{
  lib,
  stdenv,
}:
{
  postPatch = ''
    substituteInPlace __init__.py \
      --replace-warn "os.makedirs(extentions_folder)" "pass" \
      --replace-warn "os.makedirs(extentions_folder, exist_ok=True)" "pass" \
      --replace-fail "result = filecmp.dircmp(javascript_folder, extentions_folder)" "result = None" \
      --replace-fail "if result.left_only or result.diff_files:" "if False:"
  '';
}
