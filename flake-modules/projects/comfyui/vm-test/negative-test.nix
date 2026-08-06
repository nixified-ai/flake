{ pkgs, nixosModule, ... }:
let
  lib = pkgs.lib;

  test-workflow = pkgs.writeText "negative-test-workflow.json" (
    builtins.toJSON {
      "1" = {
        class_type = "NonExistingNodeClass";
        inputs = { };
      };
    }
  );

  apiTest = pkgs.writeShellScript "api-negative-test" ''
        ${pkgs.lib.getExe pkgs.python3} -c '
    import urllib.request, urllib.error, json, sys

    prompt = json.loads("""${builtins.readFile test-workflow}""")
    p = {"prompt": prompt}
    data = json.dumps(p).encode("utf-8")
    req = urllib.request.Request("http://127.0.0.1:8189/prompt", data=data)

    try:
        urllib.request.urlopen(req)
        print("Error: expected HTTP 400 Bad Request but request succeeded!", file=sys.stderr)
        sys.exit(1)
    except urllib.error.HTTPError as e:
        if e.code == 400:
            print("Success: got expected HTTP 400 Bad Request error")
            sys.exit(0)
        else:
            print(f"Error: expected HTTP 400 but got {e.code}", file=sys.stderr)
            sys.exit(1)
    except Exception as e:
        print(f"Error: expected HTTP 400 but got other exception: {e}", file=sys.stderr)
        sys.exit(1)
    '
  '';
in
pkgs.testers.nixosTest {
  name = "comfyui-negative-test";
  containers.machine =
    { pkgs, ... }:
    {
      imports = [ nixosModule ];
      services.comfyui = {
        enable = true;
        host = "::,0.0.0.0";
        port = 8189;
        acceleration = false;
      };
      systemd.services.comfyui.serviceConfig = {
        PrivateUsers = lib.mkForce false;
        ProtectSystem = lib.mkForce false;
      };
    };
  testScript =
    { nodes, ... }:
    ''
      start_all()
      machine.wait_for_unit("multi-user.target")
      machine.wait_for_unit("comfyui.service")
      machine.wait_for_open_port(8189)
      machine.succeed("${apiTest}")
    '';
}
