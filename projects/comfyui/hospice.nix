# this is the hospice: here we
# - keep things around until everyone has forgotten about them
# - provide a comfortable EOL transition
{
  lib,
  baseModels,
  typeFromInstallPath,
  ecosystemOf,
}: rec {
  # TEMP: compat with old way of adding models with a deprecation warning
  deprecationMsg = name: ''
    Model declaration "${name}": This way of declaring models is deprecated.
    The new way is to use `installModels` on a set of models declared in the following style:
    ```
    installModels {
      "loras/example1.safetensors" = { air = "urn:air:flux1:lora:civitai:<id>@<version>"; sha256 = "<hash>"; };
      "loras/example2.safetensors" = { file = inputs.my-lora-file; base = baseModels.sd15; };
      "checkpoints/example3.safetensors" = { url = "..."; sha256 = "<hash>"; base = baseModels.flux1-s; };
    }
    ```
    For now it will be accepted, but support for this will eventually be removed.
  '';

  warnIfDeprecatedModelInstall = attrName: model:
    lib.warnIf (builtins.isAttrs model && builtins.hasAttr "installPath" model && builtins.hasAttr "src" model) (deprecationMsg attrName);

  mapCompatModelInstall = f: attrName: model:
    warnIfDeprecatedModelInstall attrName model
    (f (compatInstallPath attrName model) (compatModel attrName model));

  compatInstallPath = attrName: model:
    if builtins.isAttrs model
    then model.installPath or attrName
    else attrName;

  compatModel = attrName: model:
    if !builtins.isAttrs model
    then model
    else if !builtins.hasAttr "src" model
    then model # not our problem
    else let
      baseModelCompatMap = {
        "flux1d" = baseModels.flux1-d;
        "flux1s" = baseModels.flux1-s;
        "sd3-medium" = baseModels.sd3;
        "sd15" = baseModels.sd15;
        "sdxl" = baseModels.sdxl1;
        "svd" = null;
        "svdxt" = null;
      };
      installPath = compatInstallPath attrName model;
      type =
        lib.warnIf (builtins.isString (model.type or null))
        "Model declaration ${installPath}: declared type will be ignored and automatically inferred from install location"
        (typeFromInstallPath installPath);
      base =
        if builtins.isString (model.base or null)
        then baseModelCompatMap."${model.base}" or null
        else null;
      ecosystem =
        if builtins.hasAttr "ecosystem" model && builtins.isString model.ecosystem
        then ecosystemOf base
        else model.ecosystem or null;
      meta =
        lib.optionalAttrs (!isNull type) {inherit type;}
        // lib.optionalAttrs (!isNull base) {inherit base;}
        // lib.optionalAttrs (!isNull ecosystem) {inherit ecosystem;};
    in
      lib.attrsets.recursiveUpdate {inherit meta;} model.src;

  fetchFromHuggingFace = {
    owner,
    repo,
    sha256,
    rev ? "main",
    resource ? "",
  }:
    lib.warn ''
      fetchFromHuggingFace is deprecated and will be removed in the near future; it is literally just fetching this:
      "https://huggingface.co/''${owner}/''${repo}/resolve/''${rev}/''${resource}"
    '' (import <nix/fetchurl.nix> {
      inherit sha256;
      url = "https://huggingface.co/${owner}/${repo}/resolve/${rev}/${resource}";
    });
}
