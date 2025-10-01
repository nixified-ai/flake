{ nixosTest, nixosModule, lib, python3, writeShellScript, nixified-ai }:
nixosTest {
  name = "comfyui";
  nodes.machine = { pkgs, ... }: {
    imports = [ nixosModule ];
    virtualisation.memorySize = 12288;
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
      customNodes = with pkgs.comfyuiPackages; [
        comfyui-adv-clip-emb
        comfyui-advanced-controlnet
        comfyui-controlnet-preprocessors
        comfyui-easy-use
        comfyui-essentials
        comfyui-impact-pack
        comfyui-impact-subpack
        comfyui-inpaint
        comfyui-ip-adapter
        comfyui-kjnodes
        comfyui-last-frame-extractor
        comfyui-layer-style
        comfyui-mxtoolkit
        comfyui-pythongosssss-custom-scripts
        comfyui-rgthree
        comfyui-sdxl-prompt-styler
        comfyui-tiled-diffusion
        comfyui-unload-model
        comfyui-was-node-suite
      ];
      models = with nixified-ai.models; [
        clip_vision_vit_h-upscaler
        control-lora-rank128-v11p-sd15-canny-fp16
        face-yolov8m
        hyper-sd15-1step-lora
        ip-adapter-plus-sd15
        stable-diffusion-v1-5
      ];
    };
  };
  testScript = { nodes, ... }: let
    imagePath1 = "${nodes.machine.services.comfyui.home}/.local/share/comfyui/output/ComfyUI_00001.png";
    imagePath2 = "${nodes.machine.services.comfyui.home}/.local/share/comfyui/output/ComfyUI_00001_.png";
    apiTest = writeShellScript "" ''
      ${lib.getExe python3} ${./api.py} ${./custom-nodes-test.json} --port ${toString nodes.machine.services.comfyui.port}
    '';
  in ''
    start_all()
    machine.wait_for_unit("multi-user.target")
    machine.wait_for_unit("comfyui.service")
    machine.wait_for_open_port(${toString nodes.machine.services.comfyui.port})
    machine.succeed("${apiTest}")
    machine.wait_for_file("${imagePath1}")
    machine.wait_for_file("${imagePath2}")
    machine.copy_from_vm("${imagePath1}")
    machine.copy_from_vm("${imagePath2}")
  '';
}

