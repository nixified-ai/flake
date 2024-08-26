# implementation of a fetcher based on the AIR spec https://github.com/civitai/civitai/wiki/AIR-%E2%80%90-Uniform-Resource-Names-for-AI
{
  lib,
  fetchurl,
  parseAIR,
}: let
  optStrFn = f: x: lib.optionalString (!(isNull x)) (f x);
in
  {
    air,
    sha256,
    authToken ? null,
  }: let
    constants = import ./constants.nix {inherit lib;};
    parsed = parseAIR air;
    params = ps: "?" + builtins.concatStringsSep "&" (builtins.filter (x: x != "") ps);
    url =
      if isNull parsed.version
      # not sure why the spec has version as optional when civitai's download urls seemingly rely on it
      then throw "a model version is required (...:<model>@<version>) in order to fetch this AI resource"
      else if parsed.source == "civitai"
      then
        # ex:
        # AIR: urn:air:flux1:lora:civitai:685229@766909
        # URL: https://civitai.com/api/download/models/766909?type=Model&format=SafeTensor
        "https://${parsed.source}.com/api/download/models/${parsed.version}"
        + (params [
          (
            if parsed.type == constants.modelTypes.vae.urn
            then "type=VAE"
            else "type=Model" # don't know what other cases there are to handle
          )
          (optStrFn (s: "format=${s}") parsed.format) # necessary?
        ])
      else if parsed.source == "huggingface"
      then
        # ex:
        # AIR: urn:air:sdxl:vae:huggingface:stabilityai/sdxl-vae@sdxl_vae.safetensors
        # URL: https://huggingface.co/stabilityai/sdxl-vae/resolve/main/sdxl_vae.safetensors?download=true
        # WARN: AIR does not support '/' in versions (such as resources in subdirectories), nor '.' in version ids (e.g. filenames with more than one '.')
        # I don't know which is more disappointing: huggingface's lack of unique resource ids or AIR's design.
        let
          spl = lib.strings.splitString "/" parsed.model;
          owner =
            lib.throwIf (builtins.length spl < 2) "huggingface AIR requires that the model id is of the format <repo-owner>/<repo-name>"
            (builtins.head spl);
          repo = builtins.elemAt spl 1;
          # this pattern is quite hacky and unintuitive
          # there should only ever appear one '/' in user+repo, so any subsequent '/'s can be taken as relative path delimiter...
          # ugh, it's so ugly...
          subdir = builtins.concatStringsSep "/" (lib.lists.drop 2 spl);
          resource = lib.optionalString (subdir != "") "${subdir}/" + parsed.version + optStrFn (s: ".${s}") parsed.format;
        in "https://${parsed.source}.co/${owner}/${repo}/resolve/main/${resource}?download=true"
      else lib.throw "support for constructing URL from AIR with ${parsed.source} as source has not been added yet";

    name = with parsed; lib.strings.sanitizeDerivationName "${ecosystem.urn}-${type.urn}-${model}-${version}";
    authAttr = lib.optionalAttrs (!(isNull authToken)) {curlOptsList = ["--header" "Authorization: Bearer ${authToken}"];};
    metaAttr = {
      meta =
        {
          inherit air;
          inherit (parsed) ecosystem type format;
        }
        // (
          if (parsed.source == "civitai")
          then {homepage = with parsed; "https://${source}.com/models/${model}?modelVersionId=${version}";}
          else if (parsed.source == "huggingface")
          then {homepage = lib.strings.replaceStrings ["resolve/" "?download=true"] ["blob/" ""] url;}
          else {}
        );
    };
  in
    fetchurl ({inherit name url sha256;} // authAttr)
    // metaAttr
