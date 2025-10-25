{
  nixConfig = {
    extra-trusted-substituters = [
      "https://ai.cachix.org"
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
      "https://cuda-maintainers.cachix.org"
      "https://numtide.cachix.org"
    ];
    extra-substituters = [
      "https://ai.cachix.org"
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
      "https://cuda-maintainers.cachix.org"
      "https://numtide.cachix.org"
    ];
    extra-trusted-public-keys = [
      "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
    ];
  };

  description = "A Nix Flake that makes AI reproducible and easy to run";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs?rev=01f116e4df6a15f4ccdffb1bcd41096869fb385c";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    hercules-ci-effects = {
      url = "github:hercules-ci/hercules-ci-effects";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      flake-parts,
      hercules-ci-effects,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      perSystem =
        {
          system,
          pkgs,
          self',
          lib,
          ...
        }:
        let
          common = {
            overlays = [
              inputs.self.overlays.comfyui
              inputs.self.overlays.models
              inputs.self.overlays.fetchers
            ];
            inherit system;
          };
        in
        {
          _module.args.rocmPkgs = import inputs.nixpkgs (
            {
              config = {
                rocmSupport = true;
                allowUnfree = true;
              };
            }
            // common
          );
          _module.args.nvidiaPkgs = import inputs.nixpkgs (
            {
              config = {
                cudaSupport = true;
                allowUnfree = true;
              };
            }
            // common
          );
          _module.args.pkgs = import inputs.nixpkgs ({
            inherit system;
          });
          formatter = pkgs.nixfmt-tree;
          devShells.default = pkgs.mkShell {
            packages = [
              # adds treefmt which can be used to format entire tree
              pkgs.nixfmt-tree
              # format individual file or stdin (useful for piping from nix eval)
              pkgs.nixfmt
              pkgs.npins

            ]
            ++ (lib.attrValues self'.legacyPackages.nixified-ai.internal);
          };
        };
      imports = [
        ./flake-modules
        hercules-ci-effects.flakeModule
      ];
    };
}
