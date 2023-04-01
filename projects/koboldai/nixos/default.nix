{ config, lib, ... }:

let
  inherit (lib)
    mkIf mkOption mkEnableOption types
    escapeShellArgs getExe optional
  ;

  cfg = config.services.koboldai;
in

{
  options.services.koboldai= {
    enable = mkEnableOption "KoboldAI Web UI";

    package = mkOption {
      description = "Which KoboldAI package to use.";
      type = types.package;
    };

    user = mkOption {
      description = "Which user to run KoboldAI as.";
      default = "koboldai";
      type = types.str;
    };

    group = mkOption {
      description = "Which group to run KoboldAI as.";
      default = "koboldai";
      type = types.str;
    };

    host = mkOption {
      description = "Whether to make KoboldAI remotely accessible.";
      default = false;
      type = types.bool;
    };

    port = mkOption {
      description = "Which port to listen on.";
      default = 5000;
      type = types.port;
    };

    dataDir = mkOption {
      description = "Where to store KoboldAI's state.";
      default = "/var/lib/koboldai";
      type = types.path;
    };

    extraArgs = mkOption {
      description = "Extra command line arguments.";
      default = [];
      type = with types; listOf str;
    };
  };

  config = let
    cliArgs = (optional cfg.host "--host") ++ [
      "--port" cfg.port
    ] ++ cfg.extraArgs;
  in mkIf cfg.enable {
    users.users = mkIf (cfg.user == "koboldai") {
      koboldai = {
        isSystemUser = true;
        inherit (cfg) group;
      };
    };
    users.groups = mkIf (cfg.group == "koboldai") {
      koboldai = {};
    };
    systemd.services.koboldai = {
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment.HOME = cfg.dataDir;
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${getExe cfg.package} ${escapeShellArgs cliArgs}";
        PrivateTmp = true;
      };
    };
    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0755 ${cfg.user} ${cfg.group} - -"
    ];
  };
}
