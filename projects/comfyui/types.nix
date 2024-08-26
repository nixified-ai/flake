{lib}: let
  t = lib.types;
in rec {
  # `expectType` takes a type (as in lib.types.*), what to call the value (name or epithet), and the actual value itself.
  # returns the value if it type checks; throws an error if it doesn't.
  expectType = expectedType: expectedDesc: value: let
    actualType =
      if builtins.isList value
      then "a list of ${builtins.concatStringsSep "|" (lib.lists.unique (map builtins.typeOf value))}"
      else if builtins.isFunction value
      then "a function"
      else if lib.isDerivation value
      then "a derivation"
      else if builtins.isAttrs value
      then "an attrset of type {${builtins.concatStringsSep "; " (lib.mapAttrsToList (k: v: "${k} : ${builtins.typeOf v}") value)}}"
      else "of type ${builtins.typeOf value}";
    errMsg = "${expectedDesc} (${actualType}) was expected to be of type ${expectedType.name} (${expectedType.description})";
  in
    assert lib.assertMsg (expectedType.check value) errMsg; value;

  isCustomNode = customNode.check;
  customNode =
    t.package
    // {
      name = "customNode";
      description = "custom node python package";
    };
  installPath =
    # probably should have an extension as well, but don't want to assume too much
    t.strMatching ".*/.*"
    // {
      name = "installPath";
      description = "relative install path";
    };
  isModel = model.check;
  model =
    t.addCheck t.pathInStore (x: lib.pathIsRegularFile x)
    // {
      name = "modelResource";
      description = "model file in the nix store";
    };
}
