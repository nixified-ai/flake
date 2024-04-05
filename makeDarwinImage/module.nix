{ config, lib, pkgs, ... }:
let
  cfg = config.services.macos-ventura;
in
{
  options.services.macos-ventura = {
    enable = lib.mkEnableOption "macos-ventura";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.macos-ventura-image;
      defaultText = "pkgs.macos-ventura-image";
      description = ''
        Which macOS-ventura-image derivation to use.
      '';
    };
    dataDir = lib.mkOption {
      default = "/var/lib/nixtheplanet-macos-ventura";
      type = lib.types.str;
    };
    vncListenAddr = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = lib.mdDoc ''
        Address to bind VNC (Virtual Desktop) to
      '';
    };
    vncDisplayNumber = lib.mkOption {
      type = lib.types.port;
      default = 0;
      description = lib.mdDoc ''
        Port to bind VNC (Virtual Desktop) to, added to 5900, e.g 1 means the
        VNC will run on port 5901
      '';
    };
    sshListenAddr = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = lib.mdDoc ''
        Address on which to listen for forwarding the VM port 22 to the host
      '';
    };
    sshPort = lib.mkOption {
      type = lib.types.port;
      default = 2222;
      description = lib.mdDoc ''
        Port to forward on the host to VM port 22
      '';
    };
    threads = lib.mkOption {
      type = lib.types.int;
      default = 4;
      description = lib.mdDoc ''
        Number of qemu CPU threads to assign
      '';
    };
    cores = lib.mkOption {
      type = lib.types.int;
      default = 2;
      description = lib.mdDoc ''
        Number of qemu CPU cores to assign
      '';
    };
    sockets = lib.mkOption {
      type = lib.types.int;
      default = 1;
      description = lib.mdDoc ''
        Number of qemu CPU sockets to assign
      '';
    };
    mem = lib.mkOption {
      type = lib.types.str;
      default = "4G";
      description = lib.mdDoc ''
        Amount of qemu memory to assign
      '';
    };
    extraQemuFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = lib.mdDoc ''
        A list of extra flags to pass to qemu
      '';
    };
    stateless = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc ''
        If set, all state will be removed on startup of the service, removing
        all data associated with the VM, giving you a fresh VM on each service
        start.
      '';
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc ''
        Whether to open the sshPort and vncDisplayNumber on the networking.firewall
      '';
    };
    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = lib.mdDoc ''
        Whether to automatically start the VM after booting the host machine.
      '';
    };
  };
  config = let
    run-macos = cfg.package.makeRunScript {
      diskImage = cfg.package;
      extraQemuFlags = [ "-vnc ${cfg.vncListenAddr}:${toString cfg.vncDisplayNumber}" ] ++ cfg.extraQemuFlags;
      inherit (cfg) threads cores sockets mem sshListenAddr sshPort;
    };
  in lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.optionals cfg.openFirewall [ (5900 + cfg.vncDisplayNumber) cfg.sshPort ];

    users.users.macos-ventura = {
      isSystemUser = true;
      group = "macos-ventura";
    };
    users.groups.macos-ventura = {};
    nix.settings.allowed-users = [ "macos-ventura" ];

    systemd = {
      services.macos-ventura = {
        preStart = lib.optionalString cfg.stateless ''
          rm -f *.qcow2
        '';
        description = "macOS Ventura";
        wantedBy = lib.optionals cfg.autoStart [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${lib.getExe run-macos}";
          Restart = "always";
          DynamicUser = true;
          StateDirectory = baseNameOf cfg.dataDir;
          WorkingDirectory = cfg.dataDir;
        };
      };
    };
  };
}

