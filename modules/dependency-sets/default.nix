{ lib, ... }:

let
  inherit (lib) mkOption types;
in

{
  perSystem.options = {
    dependencySets = mkOption {
      description = "Specially instantiated dependency sets for customized builds";
      type = with types; lazyAttrsOf unspecified;
      default = {};
    };
  };
}
