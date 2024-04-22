{
  description = "Description for the project";

  inputs = {
    nixified-ai.url = "github:nixified-ai/flake";
    # no need to depend on different versions of the same inputs
    flake-parts.follows = "nixified-ai/flake-parts";
    nixpkgs.follows = "nixified-ai/nixpkgs";
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
        vendor = "nvidia";
        comfyui = inputs'.nixified-ai.packages."comfyui-${vendor}";

        myModels = {
          good-model = with inputs'.nixified-ai.legacyPackages.comfyui; {
            installPath = "checkpoints/good-model.safetensors";
            src = pkgs.writeText "fake-good-model.safetensors" "";
            # src = fetchFromHuggingFace {
            #   owner = "good-person";
            #   repo = "good-models";
            #   resource = "good/model.safetensors";
            #   # leave as `""` and build once to get actual hash
            #   sha256 = "";
            # };
            type = model-types.checkpoint;
            base = base-models.sd3-medium;
          };
        };
      in {
        packages.default = self'.packages.comfyui;
        packages.comfyui = comfyui.override rec {
          # good-model is a dependency of good-node, so it will be added anyway
          # models = {inherit (myModels) good-model;};

          customNodes = {
            # random example node which we say requires good-model
            good-node = pkgs.stdenv.mkDerivation {
              pname = "good-node";
              version = "0.0.0";
              src = pkgs.fetchFromGitHub {
                owner = "Suzie1";
                repo = "ComfyUI_Guide_To_Making_Custom_Nodes";
                rev = "9d64214cfd53a89769541c645f921f0acb0c38f1";
                sha256 = "sha256-ol9Ep+K/LOaDJxWEBP+tENWCaEw8EnzlEEDtaPurmBE=";
              };
              installPhase = ''
                runHook preInstall
                mkdir -p $out/
                cp -r $src/* $out/
                runHook postInstall
              '';
              passthru.dependencies = {
                pkgs = [];
                models = {inherit (myModels) good-model;};
              };
            };
          };

          outputPath = "/tmp/comfyui-output";
          extraArgs = ["--preview-method auto"];
          # these are the defaults
          # basePath = "/var/lib/comfyui";
          # inputPath = "${basePath}/input";
          # outputPath = "${basePath}/output";
          # tempPath = "${basePath}/temp";
          # userPath = "${basePath}/user";
          # extraArgs = [];
        };
      };
    };
}
