{ nixosTest, nixosModule, lib, python3, writeShellScript, nixified-ai }:
let
  apiTest = writeShellScript "" ''
    ${lib.getExe python3} ${./api.py} ${./photo-of-a-cat.json}
  '';
in
nixosTest {
  name = "comfyui";
  machine = { pkgs, ... }: {
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
      host = "0.0.0.0";
      extraFlags = [
        "--deterministic"
        "--fast"
      ];
      acceleration = false;
      customNodes = with pkgs.comfyuiPackages; [
        comfyui-impact-pack
      ];
      models = with nixified-ai.models; [
        hyper-sd15-1step-lora
        stable-diffusion-v1-5
      ];
    };
  };
  testScript = { nodes, ... }: let
    imagePath = "${nodes.machine.services.comfyui.home}/.local/share/comfyui/output/ComfyUI_00001_.png";
  in ''
    start_all()
    machine.wait_for_unit("multi-user.target")
    machine.wait_for_unit("comfyui.service")
    machine.wait_for_open_port(8188)
    machine.succeed("${apiTest}")
    machine.wait_for_file("${imagePath}")
    machine.copy_from_vm("${imagePath}")
  '';
}

