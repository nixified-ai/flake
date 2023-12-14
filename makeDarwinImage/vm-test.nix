{ nixosTest, nixosModule, openssh, sshpass, writeShellScript }:
nixosTest {
  name = "macos-ventura";
  nodes = {
    machine = { config, ... }: {
      virtualisation.memorySize = 6144;
      imports = [ nixosModule ];
      environment.systemPackages = [ openssh sshpass ];
      networking.firewall.allowedTCPPorts = [ 5900 "${toString config.services.macos-ventura.sshPort}"];
      networking.firewall.enable = false;
      services.macos-ventura = {
        enable = true;
        cores = 1;
        threads = 1;
        mem = "4G";
        vncListenAddr = "0.0.0.0";
        extraQemuFlags = [ "-nographic" ];
        sshPort = 2021;
      };
    };
  };
  testScript = { nodes, ... }: let
    sshProductVersion = writeShellScript "foo" ''
      # Wait until a successful ssh-keyscan
      while ! ssh-keyscan -p ${toString nodes.machine.config.services.macos-ventura.sshPort} 127.0.0.1; do
          sleep 3
          echo "SSH not ready" >&2
      done
      echo "SSH ready!" >&2

      # Should return stdout like "ProductVersion:            13.6"
      sshpass -p admin ssh -o StrictHostKeyChecking=no -p ${toString nodes.machine.config.services.macos-ventura.sshPort} admin@127.0.0.1 sw_vers | grep ProductVersion | awk '{print $2}'
    '';
  in ''
    start_all()
    machine.wait_for_unit("multi-user.target")
    machine.wait_for_unit("macos-ventura.service")
    machine.wait_for_open_port(${toString nodes.machine.config.services.macos-ventura.sshPort})
    with subtest("Check that the macOS Ventura machine returns ProductVersion 13.6 via SSH"):
        assert "13.6" in machine.succeed("${sshProductVersion}")
  '';
}

