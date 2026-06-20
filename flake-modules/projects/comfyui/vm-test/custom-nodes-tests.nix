{ pkgs, nixosModule, ... }:
let
  sources = builtins.fromJSON (builtins.readFile ../customNodes-npins/sources.json);
  generate-comfyui-test-workflow = pkgs.callPackage ../scripts/generate-comfyui-test-workflow/package.nix {};

  mkTest = name: node: pkgs.nixosTest {
    name = "comfyui-custom-node-${name}";
    nodes.machine = { pkgs, ... }: {
      imports = [ nixosModule ];
      virtualisation.memorySize = 9216;
      virtualisation.cores = 1;
      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 100;
      };
      services.comfyui = {
        enable = true;
        host = "::,0.0.0.0";
        port = 8189;
        extraFlags = [
          "--deterministic"
          "--fast"
        ];
        acceleration = false;
        customNodes = [
          pkgs.comfyuiPackages.${name}
        ];
      };
    };
    testScript = { nodes, ... }: let
      test-workflow = pkgs.runCommand "test-workflow-${name}" {
        buildInputs = [ generate-comfyui-test-workflow pkgs.python3 ];
      } ''
        mkdir -p $out
        cp ${../customNodes-npins/sources.json} /build/sources.json
        cp -r ${(import ../customNodes-npins/npins/default.nix {})."ComfyUI-Manager" { inherit pkgs; }} /build/ComfyUI-Manager-source
        generate-comfyui-test-workflow ${name} > $out/workflow.json
      '';

      apiTest = pkgs.writeShellScript "" ''
        ${pkgs.lib.getExe pkgs.python3} ${./api.py} ${test-workflow}/workflow.json --port ${toString nodes.machine.services.comfyui.port}
      '';
    in ''
      start_all()
      machine.wait_for_unit("multi-user.target")
      machine.wait_for_unit("comfyui.service")
      machine.wait_for_open_port(${toString nodes.machine.services.comfyui.port})
      machine.succeed("${apiTest}")
    '';
  };
in
pkgs.lib.mapAttrs' (name: node: pkgs.lib.nameValuePair "comfyui-custom-node-${name}" (mkTest name node)) sources
