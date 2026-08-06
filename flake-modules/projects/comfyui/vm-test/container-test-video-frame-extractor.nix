{
  testers,
  nixosModule,
  lib,
  callPackage,
  python3,
  writeShellScript,
  stdenv,
  imagemagick,
}:
let
  common = callPackage ./common.nix { };

  animatedWebp = stdenv.mkDerivation {
    name = "test-animated-webp";
    buildInputs = [ imagemagick ];
    phases = [
      "buildPhase"
      "installPhase"
    ];
    buildPhase = ''
      convert -size 512x512 xc:black black.png
      convert -size 512x512 xc:white white.png
      convert -size 512x512 xc:red red.png
      convert -delay 100 -loop 0 black.png white.png red.png animated.webp
    '';
    installPhase = ''
      mkdir -p $out
      cp animated.webp $out/animated.webp
    '';
  };

in
testers.nixosTest {
  name = "comfyui-video-frame-extractor-test";
  nodes.machine =
    { pkgs, ... }:
    {
      imports = [ nixosModule ];
      virtualisation.memorySize = 4096;
      virtualisation.cores = 1;
      services.comfyui = (common.comfyuiConfig pkgs) // {
        acceleration = false;
        customNodes = [ pkgs.comfyuiPackages.comfyui-video-frame-extractor ];
      };
    };
  testScript =
    { nodes, ... }:
    let
      home = nodes.machine.services.comfyui.home;
      port = nodes.machine.services.comfyui.port;
      apiTest = writeShellScript "" ''
        ${lib.getExe python3} ${./api.py} ${./video-frame-extractor-workflow.json} --port ${toString port}
      '';
      imagePath1 = "${home}/.local/share/comfyui/output/ComfyUI_00001.png";
    in
    ''
      start_all()
      machine.wait_for_unit("multi-user.target")
      machine.wait_for_unit("comfyui.service")
      machine.wait_for_open_port(${toString port})

      # Fail the test if the logs contain any node import errors
      machine.fail("journalctl -u comfyui.service --no-pager | grep -qi 'import failed'")
      machine.fail("journalctl -u comfyui.service --no-pager | grep -qi 'cannot import'")

      # Provide input video
      machine.succeed("mkdir -p ${home}/.local/share/comfyui/input")
      machine.succeed("cp ${animatedWebp}/animated.webp ${home}/.local/share/comfyui/input/animated.webp")

      machine.succeed("${apiTest}")

      machine.sleep(5)
      print(machine.succeed("ls -la ${home}/.local/share/comfyui/output/"))
      machine.succeed("test -n \"$(ls -A ${home}/.local/share/comfyui/output/)\"")
    '';
}
