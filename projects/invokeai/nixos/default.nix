{ config, lib, ... }:

let
  inherit (lib)
    mkIf mkOption mkEnableOption mkRenamedOptionModule types
    escapeShellArgs flatten getExe mapAttrsToList
    isBool isFloat isInt isList isString
    floatToString optionalString
  ;

  cfg = config.services.invokeai;
in

{
  imports = map ({ old, new ? old }: mkRenamedOptionModule [ "services" "invokeai" old ] [ "services" "invokeai" "settings" new ]) [
    { old = "host"; }
    { old = "port"; }
    { old = "dataDir"; new = "root"; }
    { old = "precision"; }
  ];
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

    settings = mkOption {
      description = "Structured command line arguments.";
      default = { };
      type = types.submodule {
        freeformType = with types; let
          atom = nullOr (oneOf [
            bool
            str
            int
            float
          ]);
        in attrsOf (either atom (listOf atom));
        options = {
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

          root = mkOption {
            description = "Where to store InvokeAI's state.";
            default = "/var/lib/invokeai";
            type = types.path;
          };

          precision = mkOption {
            description = "Set model precision.";
            default = "auto";
            type = types.enum [ "auto" "float32" "autocast" "float16" ];
          };
        };
      };
    };

    extraArgs = mkOption {
      description = "Additional raw command line arguments.";
      default = [];
      type = with types; listOf str;
    };
  };

  config = let

    cliArgs = (flatten (mapAttrsToList (n: v:
      if v == null then []
      else if isBool v then [ "--${optionalString (!v) "no-"}${n}" ]
      else if isInt v then [ "--${n}" "${toString v}" ]
      else if isFloat v then [ "--${n}" "${floatToString v}" ]
      else if isString v then ["--${n}" v ]
      else if isList v then [ "--${n}" (toString v) ]
      else throw "Unhandled type for setting \"${n}\""
    ) cfg.settings)) ++ cfg.extraArgs;

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
      environment = {
        HOME = "${cfg.settings.root}/.home";
        INVOKEAI_ROOT = "${cfg.settings.root}";
        NIXIFIED_AI_NONINTERACTIVE = "1";
      };
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${getExe cfg.package} ${escapeShellArgs cliArgs}";
        PrivateTmp = true;
      };
    };
    systemd.tmpfiles.rules = [
      "d '${cfg.settings.root}' 0755 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.settings.root}/configs' 0755 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.settings.root}/.home' 0750 ${cfg.user} ${cfg.group} - -"
    ];
  };
}
