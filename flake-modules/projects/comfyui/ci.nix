toplevel@{ inputs, withSystem, ... }:
{
  herculesCI =
    { config, lib, ... }:
    {
      onPush = withSystem toplevel.config.defaultEffectSystem (
        { pkgs, self', ... }:
        let
          hci-effects = inputs.hercules-ci-effects.lib.withPkgs pkgs;
          mkComfyuiUpdateEffect =
            { package, description }:
            let
              title = "automation(comfyui): ${description}";
            in
            hci-effects.modularEffect {
              imports = [
                hci-effects.modules.git-update
              ];
              secretsMap.token = {
                type = "GitToken";
              };
              git.checkout.remote.url = config.repo.remoteHttpUrl;
              git.checkout.forgeType = config.repo.forgeType;
              git.update.branch = "automation/comfyui-${lib.replaceString " " "-" description}";
              git.update.baseMerge.enable = true;
              git.update.baseMerge.method = "rebase";
              git.update.pullRequest.enable = true;
              git.update.pullRequest.title = title;
              git.update.pullRequest.body = "";
              git.update.script = ''
                ${lib.getExe package}
                git add -u
                git diff-index --quiet HEAD || git commit -m "${title}"
              '';
            };
        in
        {
          comfyui-update = {
            # Daily at 3am
            # when.hour = 3;
            outputs.effects.comfyui-update = mkComfyuiUpdateEffect {
              package = self'.legacyPackages.nixified-ai.internal.comfyui-update;
              description = "update base packages";
            };
          };
          comfyui-nodes-update = {
            # Daily at 4pm
            # when.hour = 16;
            outputs.effects.comfyui-update = mkComfyuiUpdateEffect {
              package = self'.legacyPackages.nixified-ai.internal.comfyui-nodes-update;
              description = "update node packages";
            };
          };
        }
      );
    };
}
