# Inspiration from https://github.com/NixOS/nixpkgs/blob/nixos-24.11/nixos/modules/services/misc/ollama.nix
{ overlays }:
{
  config,
  lib,
  pkgs,
  ...
}@args:
let
  inherit (lib) literalExpression types;

  cfg = config.services.comfyui;
  comfyuiPackage = cfg.package.override {
    withModels = cfg.models;
    withCustomNodes = cfg.customNodes;
  };

  accelerationPkgs = let
    nvidiaPkgs = (import pkgs.path { system = pkgs.hostPlatform.system; config.cudaSupport = true; config.allowUnfree = true; overlays = overlays; });
    rocmPkgs = (import pkgs.path { system = pkgs.hostPlatform.system; config.rocmSupport = true; config.allowUnfree = true; overlays = overlays; });
  in if (cfg.acceleration == "cuda") then nvidiaPkgs else if (cfg.acceleration == "rocm") then rocmPkgs else pkgs;

  staticUser = cfg.user != null && cfg.group != null;
in
{
  options = {
    services.comfyui = {
      enable = lib.mkEnableOption "comfyui server for diffusion models";

      package = lib.mkPackageOption accelerationPkgs "comfyui" { };

      user = lib.mkOption {
        type = with types; nullOr str;
        default = null;
        example = "comfyui";
        description = ''
          User account under which to run comfyui. Defaults to [`DynamicUser`](https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#DynamicUser=)
          when set to `null`.

          The user will automatically be created, if this option is set to a non-null value.
        '';
      };

      group = lib.mkOption {
        type = with types; nullOr str;
        default = cfg.user;
        defaultText = literalExpression "config.services.comfyui.user";
        example = "comfyui";
        description = ''
          Group under which to run comfyui. Only used when `services.comfyui.user` is set.

          The group will automatically be created, if this option is set to a non-null value.
        '';
      };

      home = lib.mkOption {
        type = types.str;
        default = "/var/lib/comfyui";
        example = "/home/foo";
        description = ''
          The home directory that the comfyui service is started in.
        '';
      };

      extraFlags = lib.mkOption {
        type = types.listOf types.str;
        default = [];
        example = [ "--fast" "--deterministic" ];
        description = ''
          A list of extra string arguments to pass to comfyui
        '';
      };

      models = lib.mkOption {
        type = types.listOf types.attrs;
        default = [];
        defaultText = [];
        example = [];
        description = ''
          A list of models to fetch and supply to comfyui
        '';
      };

      customNodes = lib.mkOption {
        type = types.listOf types.attrs;
        default = [];
        defaultText = [];
        example = [];
        description = ''
          A list of custom nodes to fetch and supply to comfyui in its custom_nodes folder
        '';
      };

      host = lib.mkOption {
        type = types.str;
        default = "127.0.0.1";
        example = "[::]";
        description = ''
          The host address which the comfyui server HTTP interface listens to.
        '';
      };

      port = lib.mkOption {
        type = types.port;
        default = 8188;
        example = 11111;
        description = ''
          Which port the comfyui server listens to.
        '';
      };

      acceleration = lib.mkOption {
        type = types.nullOr (
          types.enum [
            false
            "rocm"
            "cuda"
          ]
        );
        default = null;
        example = "rocm";
        description = ''
          What interface to use for hardware acceleration.

          - `null`: default behavior
            - if `nixpkgs.config.rocmSupport` is enabled, uses `"rocm"`
            - if `nixpkgs.config.cudaSupport` is enabled, uses `"cuda"`
            - otherwise defaults to `false`
          - `false`: disable GPU, only use CPU
          - `"rocm"`: supported by most modern AMD GPUs
            - may require overriding gpu type with `services.comfyui.rocmOverrideGfx`
              if rocm doesn't detect your AMD gpu
          - `"cuda"`: supported by most modern NVIDIA GPUs
        '';
      };

      rocmOverrideGfx = lib.mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "10.3.0";
        description = ''
          Override what rocm will detect your gpu model as.
          For example, if you have an RX 5700 XT, try setting this to `"10.1.0"` (gfx 1010).

          This sets the value of `HSA_OVERRIDE_GFX_VERSION`.
        '';
      };

      environmentVariables = lib.mkOption {
        type = types.attrsOf types.str;
        default = { };
        example = {
          HIP_VISIBLE_DEVICES = "0,1";
        };
        description = ''
          Set arbitrary environment variables for the comfyui service.

          Be aware that these are only seen by the comfyui server (systemd service),
          not normal invocations like `comfyui run`.
          Since `comfyui run` is mostly a shell around the comfyui server, this is usually sufficient.
        '';
      };

      openFirewall = lib.mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to open the firewall for comfyui.

          This adds `services.comfyui.port` to `networking.firewall.allowedTCPPorts`.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users = lib.mkIf staticUser {
      users.${cfg.user} = {
        inherit (cfg) home;
        isSystemUser = true;
        group = cfg.group;
      };
      groups.${cfg.group} = { };
    };

    systemd.services.comfyui = {
      description = "comfyui";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      environment = cfg.environmentVariables // { HOME = cfg.home; };
      serviceConfig =
        lib.optionalAttrs staticUser {
          User = cfg.user;
          Group = cfg.group;
        }
        // {
          Type = "exec";
          DynamicUser = true;
          ExecStart = lib.concatStringsSep " " [
            "${lib.getExe comfyuiPackage} --listen ${cfg.host} ${lib.optionalString (cfg.acceleration == false) "--cpu"}"
            (lib.escapeShellArgs cfg.extraFlags)
          ];
          WorkingDirectory = cfg.home;
          StateDirectory = [ "comfyui" ];
          ReadWritePaths = [
            cfg.home
          ];

          CapabilityBoundingSet = [ "" ];
          DeviceAllow = [
            # CUDA
            # https://docs.nvidia.com/dgx/pdf/dgx-os-5-user-guide.pdf
            "char-nvidiactl"
            "char-nvidia-caps"
            "char-nvidia-frontend"
            "char-nvidia-uvm"
            # ROCm
            "char-drm"
            "char-kfd"
          ];
          DevicePolicy = "closed";
          LockPersonality = true;

          NoNewPrivileges = true;
          PrivateDevices = false; # hides acceleration devices
          PrivateTmp = true;
          PrivateUsers = true;
          ProcSubset = "all"; # /proc/meminfo
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          RemoveIPC = true;
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_UNIX"
          ];
          SupplementaryGroups = [ "render" ]; # for rocm to access /dev/dri/renderD* devices
          SystemCallArchitectures = "native";
          SystemCallFilter = [
            "@system-service @resources"
            "~@privileged"
          ];
          UMask = "0077";

          # MemoryDenyWriteExecute would be nice, but pytorch doesn't work with
          # this option set to true It throws the following, likely due to
          # generating assembly at runtime and marking it as executable
          #
          #  File "/nix/store/4b0mw59pv52w2kvli1hraqcybww0yy0z-python3.12-torch-2.5.1/lib/python3.12/site-packages/torch/nn/modules/conv.py", line 549, in _conv_forward
          #    return F.conv2d(
          #           ^^^^^^^^^
          #  RuntimeError: could not create a primitive

          # MemoryDenyWriteExecute = true;

        };
    };

    networking.firewall = lib.mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };
  };
}
