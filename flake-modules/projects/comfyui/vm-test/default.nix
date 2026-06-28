{
  testers,
  nixosModule,
  callPackage,
}:
let
  common = callPackage ./common.nix { };
in
testers.nixosTest {
  name = "comfyui";
  nodes.machine =
    { pkgs, ... }:
    {
      imports = [ nixosModule ];
      virtualisation.memorySize = 12288;
      virtualisation.cores = 1;
      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 100;
      };
      services.comfyui = (common.comfyuiConfig pkgs) // {
        acceleration = false;
      };
    };
  testScript =
    { nodes, ... }:
    common.testScript {
      home = nodes.machine.services.comfyui.home;
      port = nodes.machine.services.comfyui.port;
    };
}
