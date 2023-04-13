{ self, ... }:

{
  perSystem = { pkgs, system, ... }:
  let
    mkIsoImage = { gpuType, system, pkgs, self }: let
      nixosSystem = self.inputs.nixpkgs.lib.nixosSystem {
        inherit system;
      modules = [
        "${pkgs.path}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
        ({ config, pkgs, ... }:
        let
          launch-invokeai = let
            desktopItem = pkgs.makeDesktopItem {
              name = "launch-invokeai";
              desktopName = "Launch InvokeAI";
              exec = "${script}/bin/launch-invokeai.sh";
#               icon = "nix-snowflake";
#               categories = [ "Network" ];
            };
            script = pkgs.writeShellScriptBin "launch-invokeai.sh" ''
              ${pkgs.lib.getExe pkgs.chromium} http://127.0.0.1:${toString config.services.invokeai.port}
            '';
            join = pkgs.symlinkJoin {
              name = "launch-invokeai";
              paths = [
                desktopItem
                script
              ];
            };
            autostartItem = pkgs.makeAutostartItem {
              name = "launch-invokeai";
              package = join;
            };
          in autostartItem;
        in
        {
          imports = [ self.nixosModules."invokeai-${gpuType}" ];
          environment.systemPackages = [
            launch-invokeai
          ];
        })
      ];
    };
    in nixosSystem.config.system.build.isoImage;
  in
  {
    packages = {
      iso-image-nvidia = mkIsoImage { gpuType = "nvidia"; inherit system pkgs self; };
      iso-image-amd = mkIsoImage { gpuType = "amd"; inherit system pkgs self; };
    };
  };
}
