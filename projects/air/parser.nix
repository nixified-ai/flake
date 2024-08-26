{lib}: urn: let
  orNull = p: x:
    if p x
    then x
    else null;
  parts = let
    # the valid patterns for each component of the URN
    # https://github.com/civitai/civitai/wiki/AIR-%E2%80%90-Uniform-Resource-Names-for-AI#spec
    id = "[a-zA-Z0-9_\\/\\-]+"; # was bit by unexpected behaviour in the pattern "[\\-\\/]" - apparently those characters do not commute
    idNoSlash = "[a-zA-Z0-9_\\-]+";

    ecosystem = id;
    type = id;
    source = id;
    model = id;
    version = idNoSlash;
    format = idNoSlash;

    pat = "^urn:air:(${ecosystem}):(${type}):(${source}):(${model})@?(${version})?\\.?(${format})?$";
  in
    # TODO: we can avoid depending on lib by being less fancy
    lib.pipe (builtins.split pat urn) [
      # there should be three components in the split
      (lib.mapNullable (orNull (x: builtins.length x == 3)))
      # we want the middle one
      (lib.mapNullable (x: builtins.elemAt x 1))
      # verify that there are 6 elements
      (lib.mapNullable (orNull (x: builtins.length x == 6)))
      # throw if anything went wrong
      (x: lib.throwIf (isNull x) "invalid AIR: ${urn}" x)
    ];
  part = builtins.elemAt parts;
  constants = import ./constants.nix {inherit lib;};
in {
  ecosystem =
    lib.lists.findSingle (x: x.urn == part 0) null (throw "more than one ecosystem with the name ${part 0}")
    (builtins.attrValues constants.ecosystems);
  type =
    lib.lists.findSingle (x: x.urn == part 1) null (throw "more than one type with the name ${part 1}")
    (builtins.attrValues constants.modelTypes);
  source = part 2;
  model = part 3;
  version = part 4;
  format = part 5;
}
