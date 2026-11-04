{ pkgs, nixosModule, ... }:
let
  lib = pkgs.lib;

  # Define the custom node package locally
  freezeStringNodePkg = pkgs.stdenv.mkDerivation {
    pname = "comfyui-freeze-string";
    version = "0.1.0";
    src = ../../../../ComfyUI-FreezeString;
    installPhase = ''
      mkdir -p $out/${pkgs.python3.sitePackages}/custom_nodes/ComfyUI-FreezeString
      cp -r * $out/${pkgs.python3.sitePackages}/custom_nodes/ComfyUI-FreezeString/
    '';
  };

  # Define a test output node package to capture output
  testOutputNodePkg = pkgs.writeTextFile {
    name = "comfyui-test-output-node";
    destination = "/${pkgs.python3.sitePackages}/custom_nodes/test_output_node/__init__.py";
    text = ''
      class TestOutputNode:
          @classmethod
          def INPUT_TYPES(s):
              return {
                  "required": {
                      "text": ("STRING", {"forceInput": True}),
                  }
              }
          RETURN_TYPES = ()
          FUNCTION = "save_text"
          OUTPUT_NODE = True
          CATEGORY = "test"
          def save_text(self, text):
              return {"ui": {"text": [text]}}

      NODE_CLASS_MAPPINGS = {
          "TestOutputNode": TestOutputNode
      }
    '';
  };

  apiTest = pkgs.writeShellScript "api-freeze-string-test" ''
    ${pkgs.lib.getExe pkgs.python3} ${./freeze-string-test.py}
  '';
in
pkgs.testers.nixosTest {
  name = "comfyui-freeze-string-test";
  containers.machine =
    { pkgs, ... }:
    {
      imports = [ nixosModule ];
      services.comfyui = {
        enable = true;
        host = "::,0.0.0.0";
        port = 8189;
        acceleration = false;
        customNodes = [
          freezeStringNodePkg
          testOutputNodePkg
        ];
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
