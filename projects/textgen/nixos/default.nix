{ config, lib, ... }:
with lib;
let
  cfg = config.services.textgen;
in
{
  options.services.textgen = {
    enable = mkEnableOption (mdDoc "A WebUI for LLMs and LoRA training");
    package = mkOption {
      description = "textgen package to use.";
      type = types.package;
    };
    user = mkOption {
      type = types.str;
      default = "textgen";
      description = mdDoc "User account under which textgen runs.";
    };
    group = mkOption {
      type = types.str;
      default = "textgen";
      description = mdDoc "Group under which textgen runs.";
    };
    settings = mkOption {
      description = mdDoc ''
        Attrset that is converted to settings.yaml.
        See: <https://github.com/oobabooga/text-generation-webui/blob/main/settings-template.yaml>
      '';
      type = types.attrs;
      default = { };
    };
    settingsFile = mkOption {
      description = mdDoc ''
        Path to settings.yaml.
        This will override {option}`services.textgen.settings`.
      '';
      type = with types; nullOr path;
      # Error when settings.yaml is empty.
      default = if cfg.setting == { } then null else toYAML cfg.settings;
    };
    extraArgs = mkOption {
      description = "Additional command line arguments.";
      default = [ ];
      type = with types; listOf str;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.textgen = {
      description = "A WebUI for LLMs and LoRA training";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Restart = "on-failure";
        MountAPIVFS = true;
        ProtectProc = "invisible";
        User = cfg.user;
        Group = cfg.group;
        CapabilityBoundingSet = [ "" ];
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = "yes";
        RuntimeDirectory = "textgen";
        StateDirectory = "textgen";
        CacheDirectory = "textgen";
        PrivateTmp = true;
        PrivateIPC = true;
        PrivateUsers = true;
        ProtectHostname = true;
        ProtectClock = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        RestrictNamespaces = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
        PrivateMounts = true;
        SystemCallArchitectures = [ "native" ];
        SystemCallFilter = [ "@system-service" ];
        ExecStart = let
            args = cfg.extraArgs ++ mkIf (cfg.settingsFile != null)
              [ "--settings" "${cfg.settingsFile}" ];
          in "${cfg.package}/bin/textgen ${escapeShellArgs cfg.extraArgs}";
      };
    };

    users.users = mkIf (cfg.user == "textgen") {
      textgen = {
        description = "textgen Service";
        inherit (cfg) group;
        isSystemUser = true;
      };
    };

    users.groups = mkIf (cfg.group == "textgen") {
      textgen = {};
    };
  };
}
