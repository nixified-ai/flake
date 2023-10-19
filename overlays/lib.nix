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

    applyOverlays = packageSet: overlays: let
      combinedOverlay = lib.composeManyExtensions overlays;
    in
      # regular extensible package set
      if packageSet ? extend then
        packageSet.extend combinedOverlay
      # makeScope-style package set, this case needs to be handled before makeScopeWithSplicing
      else if packageSet ? overrideScope' then
        packageSet.overrideScope' combinedOverlay
      # makeScopeWithSplicing-style package set
      else if packageSet ? overrideScope then
        packageSet.overrideScope combinedOverlay
      else
        throw "don't know how to extend the given package set";
  };
}
