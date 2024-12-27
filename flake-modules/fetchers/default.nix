{
  flake = {
    overlays.fetchers = (self: super: {
      fetchResource = super.callPackage ./fetchresource {};
      fetchair = super.callPackage ./fetchair/fetcher.nix {
        fetchurl = args: self.fetchResource args;
      };
    });
  };
}
