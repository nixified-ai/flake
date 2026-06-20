{ pkgs, nixosModule, ... }:
let
  lib = pkgs.lib;

  normalizeUrl =
    url:
    let
      lower = lib.toLower url;
      noSlash = if lib.hasSuffix "/" lower then lib.removeSuffix "/" lower else lower;
      noGit = if lib.hasSuffix ".git" noSlash then lib.removeSuffix ".git" noSlash else noSlash;
      noSlash2 = if lib.hasSuffix "/" noGit then lib.removeSuffix "/" noGit else noGit;
    in
    noSlash2;

  nodeMapFile = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/Comfy-Org/ComfyUI-Manager/refs/heads/main/node_db/new/extension-node-map.json";
    sha256 = "sha256-ipPV6ALgPBpTiYX5SaqIGN85uEHaNzqurGiJajvXUwI=";
  };
  nodeMap = builtins.fromJSON (builtins.readFile nodeMapFile);
  normalizedNodeMapKeys = lib.mapAttrs' (
    url: value: lib.nameValuePair (normalizeUrl url) true
  ) nodeMap;

  sources = builtins.fromJSON (builtins.readFile ../customNodes-npins/sources.json);

  getRepoUrl =
    pin:
    if pin ? repository then
      let
        repo = pin.repository;
      in
      if repo.type == "GitHub" then
        "https://github.com/${repo.owner}/${repo.repo}"
      else if repo.type == "GitLab" then
        "https://gitlab.com/${repo.repo_path}"
      else if repo ? url then
        repo.url
      else
        ""
    else if pin ? url then
      let
        githubMatch = builtins.match "https://github.com/([^/]+)/([^/]+)/.*" pin.url;
        githubApiMatch = builtins.match "https://api.github.com/repos/([^/]+)/([^/]+)/.*" pin.url;
      in
      if githubMatch != null then
        "https://github.com/${builtins.elemAt githubMatch 0}/${builtins.elemAt githubMatch 1}"
      else if githubApiMatch != null then
        "https://github.com/${builtins.elemAt githubApiMatch 0}/${builtins.elemAt githubApiMatch 1}"
      else
        ""
    else
      "";

  filteredPins = lib.filterAttrs (
    name: pin:
    let
      repoUrl = getRepoUrl pin;
      normalized = normalizeUrl repoUrl;
    in
    builtins.hasAttr normalized normalizedNodeMapKeys
  ) sources.pins;

  generate-comfyui-test-workflow =
    pkgs.callPackage ../scripts/generate-comfyui-test-workflow/package.nix
      { };

  dummyOutputNodePkg = pkgs.writeTextFile {
    name = "comfyui-dummy-output-node";
    destination = "/${pkgs.python3.sitePackages}/custom_nodes/dummy_output_node/__init__.py";
    text = ''
      class DummyOutputNode:
          @classmethod
          def INPUT_TYPES(s):
              return {"required": {}}
          RETURN_TYPES = ()
          FUNCTION = "do_nothing"
          OUTPUT_NODE = True
          CATEGORY = "test"
          def do_nothing(self):
              return {}

      NODE_CLASS_MAPPINGS = {
          "DummyOutputNode": DummyOutputNode
      }
    '';
  };

  mkTest =
    name: node:
    pkgs.testers.nixosTest {
      name = "comfyui-custom-node-${name}";
      nodes.machine =
        { pkgs, ... }:
        {
          imports = [ nixosModule ];
          virtualisation.memorySize = 9216;
          virtualisation.cores = 1;
          zramSwap = {
            enable = true;
            algorithm = "zstd";
            memoryPercent = 100;
          };
          services.comfyui = {
            enable = true;
            host = "::,0.0.0.0";
            port = 8189;
            extraFlags = [
              "--deterministic"
              "--fast"
            ];
            acceleration = false;
            customNodes = [
              pkgs.comfyuiPackages.${name}
              dummyOutputNodePkg
            ];
          };
        };
      testScript =
        { nodes, ... }:
        let
          test-workflow =
            pkgs.runCommand "test-workflow-${name}"
              {
                buildInputs = [
                  generate-comfyui-test-workflow
                  pkgs.python3
                ];
              }
              ''
                mkdir -p $out
                generate-comfyui-test-workflow ${name} --sources ${../customNodes-npins/sources.json} --node-map ${nodeMapFile} > $out/workflow.json
              '';

          apiTest = pkgs.writeShellScript "" ''
            ${pkgs.lib.getExe pkgs.python3} ${./api.py} ${test-workflow}/workflow.json --port ${toString nodes.machine.services.comfyui.port}
          '';
        in
        ''
          start_all()
          machine.wait_for_unit("multi-user.target")
          machine.wait_for_unit("comfyui.service")
          machine.wait_for_open_port(${toString nodes.machine.services.comfyui.port})
          machine.succeed("${apiTest}")
        '';
    };
in
pkgs.lib.mapAttrs' (
  name: node: pkgs.lib.nameValuePair "comfyui-custom-node-${name}" (mkTest name node)
) filteredPins
