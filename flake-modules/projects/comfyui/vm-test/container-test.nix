{
  testers,
  nixosModule,
  lib,
  callPackage,
}:
let
  common = callPackage ./common.nix { };
in
testers.nixosTest {
  name = "comfyui-container-gpu";
  containers.machine =
    { pkgs, ... }:
    {
      imports = [ nixosModule ];

      systemd.services.comfyui.serviceConfig = {
        PrivateUsers = lib.mkForce false;
        ProtectSystem = lib.mkForce false;
      };

      hardware.graphics.enable = true;
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.nvidia.open = false;

      virtualisation.systemd-nspawn.options = [
        "--bind=/dev/nvidia0"
        "--bind=/dev/nvidiactl"
        "--bind=/dev/nvidia-uvm"
        "--bind=/dev/nvidia-uvm-tools"
      ];

      services.comfyui = (common.comfyuiConfig pkgs) // {
        acceleration = "cuda";
      };
    };
  testScript =
    { containers, ... }:
    common.testScript {
      inherit (containers.machine.services.comfyui) home port;
    };
}
