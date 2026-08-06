{
  testers,
  nixosModule,
  lib,
  callPackage,
  pkgs,
}:
let
  common = callPackage ./common.nix { };
  testOutputNodePkg = pkgs.writeTextFile {
    name = "comfyui-test-output-node";
    destination = "/${pkgs.python3.sitePackages}/custom_nodes/test_output_node/__init__.py";
    text = ''
      class TestOutputNode:
          @classmethod
          def INPUT_TYPES(s):
              return {"required": {}}
          RETURN_TYPES = ()
          FUNCTION = "save_text"
          OUTPUT_NODE = True
          CATEGORY = "test"
          def save_text(self):
              return {}

      NODE_CLASS_MAPPINGS = {
          "TestOutputNode": TestOutputNode
      }
    '';
  };
in
testers.nixosTest {
  name = "comfyui-persistent-queue-test";
  containers.machine =
    { pkgs, ... }:
    let
      uiTestScript = pkgs.writeScript "ui-test.py" ''
        #!/usr/bin/env python3
        import sys
        import asyncio
        from playwright.async_api import async_playwright

        async def run():
            print("Starting Playwright...")
            async with async_playwright() as p:
                browser = await p.chromium.launch(headless=True)
                page = await browser.new_page()

                def handle_console(msg):
                    print(f"BROWSER CONSOLE: [{msg.type}] {msg.text}")
                
                page.on("console", handle_console)
                page.on("pageerror", lambda err: print(f"BROWSER ERROR: {err}"))

                print("Fetching ComfyUI...")
                try:
                    await page.goto("http://localhost:8189", wait_until="networkidle")
                except Exception as e:
                    print("Error loading page:", e)
                
                print("Checking extensions API...")
                import urllib.request
                try:
                    resp = urllib.request.urlopen("http://localhost:8189/extensions")
                    print("Extensions API:", resp.read().decode())
                except Exception as e:
                    print("Extensions API error:", e)

                print("Waiting for Manage Saved Queue button...")
                try:
                    await page.wait_for_selector("text=Manage Saved Queue", timeout=15000)
                    print("SUCCESS! Button found.")
                except Exception as e:
                    print("FAILED to find button:")
                    print("Exception:", e)
                    print("Page Source:")
                    print(await page.content())
                    await browser.close()
                    sys.exit(1)
                
                await browser.close()

        if __name__ == "__main__":
            asyncio.run(run())
      '';
    in
    {
      imports = [ nixosModule ];

      systemd.services.comfyui.serviceConfig = {
        PrivateUsers = lib.mkForce false;
        ProtectSystem = lib.mkForce false;
      };

      services.comfyui = (common.comfyuiConfig pkgs) // {
        acceleration = false;
        customNodes = (common.comfyuiConfig pkgs).customNodes ++ [
          pkgs.comfyuiPackages.comfyui-persistent-queue
          testOutputNodePkg
        ];
      };

      environment.systemPackages = [
        pkgs.jq
        pkgs.curl
        (pkgs.python3.withPackages (ps: [ ps.playwright ]))
        pkgs.playwright-driver.browsers
      ];

      environment.variables.PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
      environment.variables.UI_TEST_SCRIPT = "${uiTestScript}";
    };

  testScript = ''
    start_all()
    machine.wait_for_unit("comfyui.service")
    machine.wait_for_open_port(8189)

    machine.succeed("curl -s -X POST http://localhost:8189/prompt -d '{\"prompt\": {\"1\": {\"class_type\": \"TestOutputNode\", \"inputs\": {}}}, \"client_id\": \"test-client\"}' > /tmp/prompt.json")
    prompt_id = machine.succeed("jq -r '.prompt_id' < /tmp/prompt.json").strip()

    # Wait a moment for queue to process/sync
    machine.sleep(2)

    # Check if it was recorded in persistent queue DB
    machine.succeed(f"curl -s http://localhost:8189/comfyui-persistent-queue/prompts | grep {prompt_id}")

    # Simulate a crash/restart
    machine.systemctl("restart comfyui.service")
    machine.wait_for_open_port(8189)

    # Verify prompt is still in our persistent DB (saved_from_crash or completed)
    machine.succeed(f"curl -s http://localhost:8189/comfyui-persistent-queue/prompts | grep {prompt_id}")

    # Run headless UI test
    machine.succeed("python3 $UI_TEST_SCRIPT >&2")
  '';
}
