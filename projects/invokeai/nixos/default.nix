{ config, lib, ... }:

let
  inherit (lib)
    mkIf mkOption mkEnableOption types
    escapeShellArgs getExe optionalString
  ;

  cfg = config.services.invokeai;
in

{
  options.services.invokeai = {
    enable = mkEnableOption "InvokeAI Web UI for Stable Diffusion";

    package = mkOption {
      description = "Which InvokeAI package to use.";
      type = types.package;
    };

    user = mkOption {
      description = "Which user to run InvokeAI as.";
      default = "invokeai";
      type = types.str;
    };

    group = mkOption {
      description = "Which group to run InvokeAI as.";
      default = "invokeai";
      type = types.str;
    };

    host = mkOption {
      description = "Which IP address to listen on.";
      default = "127.0.0.1";
      type = types.str;
    };

    port = mkOption {
      description = "Which port to listen on.";
      default = 9090;
      type = types.port;
    };

    dataDir = mkOption {
      description = "Where to store InvokeAI's state.";
      default = "/var/lib/invokeai";
      type = types.path;
    };

    maxLoadedModels = mkOption {
      description = "Maximum amount of models to keep in VRAM at once.";
      default = 1;
      type = types.ints.positive;
    };

    nsfwChecker = mkEnableOption "the NSFW Checker";

    precision = mkOption {
      description = "Set model precision.";
      default = "auto";
      type = types.enum [ "auto" "float32" "autocast" "float16" ];
    };

    extraArgs = mkOption {
      description = "Extra command line arguments.";
      default = [];
      type = with types; listOf str;
    };
  };

  config = let

    yesno = enable: text: "--${optionalString (!enable) "no-"}${text}";

    cliArgs = [
      "--web"
      "--host" cfg.host
      "--port" cfg.port
      "--root_dir" cfg.dataDir
      "--max_loaded_models" cfg.maxLoadedModels
      (yesno cfg.nsfwChecker "nsfw_checker")
      "--precision" cfg.precision
    ] ++ cfg.extraArgs;
    initialModelsPath = "${cfg.package}/${cfg.package.pythonModule.sitePackages}/invokeai/configs/INITIAL_MODELS.yaml";
  in mkIf cfg.enable {
    users.users = mkIf (cfg.user == "invokeai") {
      invokeai = {
        isSystemUser = true;
        inherit (cfg) group;
      };
    };
    users.groups = mkIf (cfg.group == "invokeai") {
      invokeai = {};
    };
    systemd.services.invokeai = {
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        ln -sf ${initialModelsPath} '${cfg.dataDir}/configs/INITIAL_MODELS.yaml'
        cp -L --no-clobber --no-preserve=mode ${initialModelsPath} '${cfg.dataDir}/configs/models.yaml'
      '';
      environment.HOME = "${cfg.dataDir}/.home";
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${getExe cfg.package} ${escapeShellArgs cliArgs}";
        PrivateTmp = true;
      };
    };
    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0755 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.dataDir}/configs' 0755 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.dataDir}/.home' 0750 ${cfg.user} ${cfg.group} - -"
    ];
  };
}
