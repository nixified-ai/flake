{
  lib,
  python3,
  writeShellScript,
}:
{
  comfyuiConfig = pkgs: {
    enable = true;
    host = "::,0.0.0.0";
    port = 8189;
    extraFlags = [
      "--deterministic"
      "--fast"
    ];
    customNodes = lib.filter (drv: drv.pname != "comfyui-rife-tensorrt-auto") (
      lib.attrValues pkgs.comfyuiCustomNodes
    );
    models = with pkgs.nixified-ai.models; [
      clip_vision_vit_h-upscaler
      control-lora-rank128-v11p-sd15-canny-fp16
      face-yolov8m
      hyper-sd15-1step-lora
      ip-adapter-plus-sd15
      stable-diffusion-v1-5
      gemma3-4b-it-gguf
      gemma3-4b-it-mmproj
    ];
  };

  testScript =
    { home, port }:
    let
      imagePath1 = "${home}/.local/share/comfyui/output/ComfyUI_00001.png";
      imagePath2 = "${home}/.local/share/comfyui/output/ComfyUI_00002_.png";
      apiTest = writeShellScript "" ''
        ${lib.getExe python3} ${./api.py} ${./custom-nodes-test.json} --port ${toString port}
      '';
    in
    ''
      start_all()
      machine.wait_for_unit("multi-user.target")
      machine.wait_for_unit("comfyui.service")
      machine.wait_for_open_port(${toString port})
      machine.succeed("${apiTest}")
      machine.wait_for_file("${imagePath1}")
      machine.wait_for_file("${imagePath2}")
      machine.copy_from_machine("${imagePath1}")
      machine.copy_from_machine("${imagePath2}")
    '';

  testScriptGemma =
    { home, port }:
    let
      inputPath1 = "${home}/.local/share/comfyui/input/ComfyUI_00001.png";
      outputPath = "${home}/.local/share/comfyui/output/gemma_output.txt";
      gemmaTest = writeShellScript "" ''
        ${lib.getExe python3} ${./api.py} ${./gemma3-test.json} --port ${toString port}
      '';
    in
    ''
      start_all()
      machine.wait_for_unit("multi-user.target")
      machine.wait_for_unit("comfyui.service")
      machine.wait_for_open_port(${toString port})

      # Provide input image for the gemma test
      machine.succeed("mkdir -p ${home}/.local/share/comfyui/input")
      machine.succeed("cp ${./ComfyUI_00001.png} ${inputPath1}")
      machine.succeed("chmod a+r ${inputPath1}")
      machine.succeed("${gemmaTest}")

      # Wait and extract the saved text output
      machine.wait_for_file("${outputPath}")
      machine.copy_from_machine("${outputPath}")
    '';
}
