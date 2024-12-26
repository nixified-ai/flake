{
  flake = {
    overlays.models = (self: super: {
      nixified-ai = (super.nixified-ai or {}) // { models = self.callPackages ./models.nix {}; };
    });
  };
}
