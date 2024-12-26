{
  inputs = {
    nixified-ai.url = "github:nixified-ai/flake/comfyui-unwrapped";

    # to avoid duplication of inputs
    flake-parts.follows = "nixified-ai/flake-parts";
    nixpkgs.follows = "nixified-ai/nixpkgs";

    # you can add your own local resources as inputs
    # my-lora = {
    #   url = "file:///path/to/my-loras/me.safetensors";
    #   flake = false;
    # };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        _module.args.pkgs = import inputs.nixpkgs ({
          inherit system;
          overlays = [
            inputs.nixified-ai.overlays.comfyui   # adds comfyuiPackages
            inputs.nixified-ai.overlays.models    # adds nixified-ai.models
            inputs.nixified-ai.overlays.fetchers  # adds fetchResource and fetchair
          ];
          config = {
            allowUnfree = true;
            cudaSupport = true; # change to rocmSupport for amd, but unlikely
                                # to work due to lack of nixpkgs maintenance
          };
        });
        packages.default = pkgs.comfyuiPackages.comfyui.override {
          # You can use pkgs.nixified-ai.models to get access to pre-packaged and configured models
          withModels = with pkgs.nixified-ai.models; [
            flux1-dev-q4_0
            flux-ae
            flux-text-encoder-1
            t5-v1_1-xxl-encoder

            # or define your own fetches discretely
            (pkgs.fetchResource {
              name = "ultrarealistic.safetensors";
              url = "https://civitai.com/api/download/models/1026423?type=Model&format=SafeTensor";
              sha256 = "B1C4DDF95671E6B51817B4F3802865E544040C232C467E76B1CB0C251BD6B634";
              passthru = {
                comfyui.installPaths = [ "loras" ];
              };
            })
          ];
          # or import from a list inside of ./models.nix
          # withModels = (builtins.attrValues (pkgs.callPackages ./models.nix {}));

          # You can get the custom-nodes from nixified-ai's overlay above
          withCustomNodes = with pkgs.comfyuiPackages; [
            comfyui-gguf
          ];

          # or call your own
          # withCustomNodes = [
          #   (pkgs.callPackage ./comfyui-gguf.nix {})
          # ];
        };
      };
    };
}
