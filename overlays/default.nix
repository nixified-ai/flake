{ lib, ... }:

let
  l = lib.extend (import ./lib.nix);

  overlaySets = {
    python = import ./python l;
  };

  prefixAttrs = prefix: lib.mapAttrs' (name: value: lib.nameValuePair "${prefix}-${name}" value);

in

{
  flake = {
    lib = {
      inherit (l) overlays;
    };
    overlays = lib.pipe overlaySets [
      (lib.mapAttrs prefixAttrs)
      (lib.attrValues)
      (lib.foldl' (a: b: a // b) {})
    ];
  };
}
