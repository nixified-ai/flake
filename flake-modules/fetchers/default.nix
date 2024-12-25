{
  flake = {
    overlays.fetchers = (self: super: {
      fetchResource = self.callPackage ./fetchresource {};
      fetchair = self.callPackage ./fetchair/fetcher.nix {
        fetchurl = args: self.fetchResource args;
      };
    });
  };
}
