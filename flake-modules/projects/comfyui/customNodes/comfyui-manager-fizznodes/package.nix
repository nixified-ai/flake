{
  lib,
  stdenv,
}:
old: {
  passthru = (old.passthru or { }) // {
    pythonDependencies =
      ps:
      let
        baseDeps =
          if (old.passthru or { }) ? pythonDependencies then old.passthru.pythonDependencies ps else [ ];
      in
      baseDeps ++ [ ps.numexpr ];
  };

  postPatch = ''
    substituteInPlace __init__.py \
      --replace-warn 'web\extensions\FizzleDorf' 'web\\extensions\\FizzleDorf' \
      --replace-warn "os.makedirs(extentions_folder)" "pass" \
      --replace-warn "os.makedirs(extentions_folder, exist_ok=True)" "pass" \
      --replace-fail "result = filecmp.dircmp(javascript_folder, extentions_folder)" "result = None" \
      --replace-fail "if result.left_only or result.diff_files:" "if False:"
  '';
}
