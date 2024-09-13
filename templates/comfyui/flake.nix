{
  description = "Description for the project";

  inputs = {
    nixified-ai.url = "github:nixified-ai/flake";
    # to avoid duplication of inputs
    flake-parts.follows = "nixified-ai/flake-parts";
    nixpkgs.follows = "nixified-ai/nixpkgs";

    # you can add your own local resources as inputs
    # my-lora = {
    #   url = "file:///path/to/my-loras/me.safetensors";
    #   flake = false;
    # };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        lib,
        ...
      }: let
        # vendor = "amd";
        vendor = "nvidia";
        comfyPkgs = inputs'.nixified-ai.legacyPackages.comfyui."${vendor}";
        models = import ./models.nix {
          inherit (comfyPkgs) installModels kritaModelInstalls modelTypes ecosystems baseModels;
          localResources = {
            # inherit (inputs) my-lora;
          };
        };
        customNodes = import ./custom-nodes.nix {
          inherit models;
          inherit (pkgs) stdenv fetchFromGitHub;
          # it's important that we use the same python3Packages as comfyui
          inherit
            (comfyPkgs)
            customNodes
            python3Packages
            ;
        };
        comfyui = comfyPkgs.comfyui.override rec {
          inherit models customNodes;
          outputPath = "/tmp/comfyui-output";
          extraArgs = [
            "--preview-method auto"
            # "--listen 0.0.0.0" # use this to make it available over LAN
          ];
          # these are the defaults
          # NOTE: these must exist and be writable by comfyui
          # basePath = "/var/lib/comfyui";
          # inputPath = "${basePath}/input";
          # outputPath = "${basePath}/output";
          # tempPath = "${basePath}/temp";
          # userPath = "${basePath}/user";
          # extraArgs = [];
        };
      in {
        packages.default = comfyui;

        legacyPackages = {inherit models customNodes;};
      };
    };
}
