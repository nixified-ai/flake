{ self, inputs, ... }:
{
  flake = {
    templates.comfyui = {
      path = ./template;
      description = "Comfyui non-nixos template. Non-nixos is not officially supported, but acts as good documentation";
    };
    overlays.comfyui = (
      self: super:
      let
        inherit (self) lib comfyuiLib customCustomNodesPins;
        customNodes = lib.mapAttrs (
          name: pin:
          let
            inherit (self) callPackage;
            basePackage = callPackage (
              { stdenv }: stdenv.mkDerivation (comfyuiLib.nodePropsFromNpinSource pin)
            ) { };
            overridesFile = ./customNodes/${name}/package.nix;
            withOverrides =
              if lib.pathExists overridesFile then
                let
                  overridePayload =
                    lib.removeAttrs (callPackage overridesFile { })
                      # these cuses issues down the line when building the package
                      # TODO: is there a way to get callPackage style dependency
                      # injection without these being added?
                      [
                        "override"
                        "overrideDerivation"
                      ];
                in
                basePackage.overrideAttrs overridePayload
              else
                basePackage;
          in
          comfyuiLib.mkComfyUICustomNode withOverrides
        ) customCustomNodesPins;
      in
      {
        customCustomNodesPins = (builtins.fromJSON (lib.readFile ./customNodes-npins/sources.json)).pins;
        comfyuiCustomNodes = customNodes;
        comfyuiLib = (self.callPackage ./lib.nix { }) // (self.callPackage ./scripts.nix { });
        comfyuiPackages =
          (self.lib.packagesFromDirectoryRecursive {
            inherit (self) callPackage;
            directory = ./pkgs;
          })
          // customNodes
          // {
            add-all-sources = comfyuiLib.make-add-github-sources self.comfyuiPackages;
            make-custom-nodes = comfyuiLib.makeCustomNodesDirTree customNodes;
            packagesNoOwner = comfyuiLib.packagesNoOwner (lib.attrValues self.comfyuiPackages);
          };
        comfyui = self.comfyuiPackages.comfyui;
      }
    );
    nixosModules.comfyui =
      { ... }:
      let
        overlays = [
          self.overlays.comfyui
          self.overlays.models
          self.overlays.fetchers
        ];
      in
      {
        imports = [ (import ./module.nix { inherit overlays; }) ];
        nixpkgs.overlays = overlays;
      };
  };
  perSystem =
    {
      config,
      pkgs,
      nvidiaPkgs,
      rocmPkgs,
      system,
      ...
    }:
    {
      checks.comfyui = pkgs.callPackage ./vm-test { nixosModule = inputs.self.nixosModules.comfyui; };
      packages = {
        # comfyui-nvidia = nvidiaPkgs.comfyuiPackages.comfyui;
        comfyui-nvidia = nvidiaPkgs.comfyuiPackages.comfyui // {
          passthru = nvidiaPkgs.comfyuiPackages.comfyui.passthru // {
            inherit (nvidiaPkgs)
              customCustomNodesPins
              comfyuiCustomNodes
              comfyuiLib
              comfyuiPackages
              ;
          };
        };
        # ROCm support in nixpkgs is pretty bad right now
        # comfyui-amd = rocmPkgs.comfyuiPackages.comfyui;
      };
    };
}
