lib: _: {
  overlays = {
    runOverlay = do: final: prev: do {
      inherit final prev;
      util = {
        callPackageOrTuple = input:
          if lib.isList input then
            assert lib.length input == 2; let
              pkg = lib.head input;
              args = lib.last input;
            in final.callPackage pkg args
          else
            final.callPackage input { };
      };
    };

    callManyPackages = packages: lib.overlays.runOverlay ({ util, ... }:
      let
        packages' = lib.listToAttrs (map (x: lib.nameValuePair (baseNameOf x) x) packages);
      in
        lib.mapAttrs (lib.const util.callPackageOrTuple) packages'
    );

    applyPackageOverrides = pkg: overlays: pkg.override {
      packageOverrides = lib.composeManyExtensions overlays;
    };
  };
}
