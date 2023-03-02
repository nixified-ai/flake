{ pkgs, ... }:

{
  systemd = {
    # Allow "unsupported" AMD GPUs
    services.invokeai.environment.HSA_OVERRIDE_GFX_VERSION = "10.3.0";
    # HACK: The PyTorch build we use on ROCm wants this to exist
    tmpfiles.rules = [
      "L+ /opt/amdgpu - - - - ${pkgs.libdrm}"
    ];
  };
}
