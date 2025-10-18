{
  lib,
}:
rec {
  sanitizeName = x: lib.replaceStrings [ "_" ] [ "-" ] (lib.toLower x);
  makePname =
    repo:
    let
      sanitized = sanitizeName repo;
      prefix = "comfyui-";
    in
    if lib.hasPrefix prefix sanitized then sanitized else "${prefix}${sanitized}"

  ;
  makeDirName = sourceName: makePname (lib.last (lib.splitString "/" sourceName));
  overrideDirTemplate = {
    "package.nix" = ''
      { }:
      finalAttrs: previousAttrs: { }
    '';
  };
  makeCustomNodesDirTree =
    customNodes:
    lib.concatMapAttrs (name: value: {
      "${makeDirName name}" = overrideDirTemplate;
    }) customNodes;
}
