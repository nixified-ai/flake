{ self, inputs, ... }:
{
  perSystem = { config, pkgs, ... }: {
    legacyPackages.nixified-ai.internal = {
      generate-comfyui-test-workflow = pkgs.callPackage ./generate-comfyui-test-workflow/package.nix {};
    };
  };
}
