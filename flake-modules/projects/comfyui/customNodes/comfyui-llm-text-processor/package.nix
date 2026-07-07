{ pkgs }:
{
  patches = [
    ./fix-folder-registry.patch
    ./fix-llama-binary.patch
  ];
  postPatch = ''
    substituteInPlace llama_binary.py \
      --replace-fail "@llama-cli@" "${pkgs.llama-cpp}/bin/llama-cli"

    substituteInPlace llama_cli.py \
      --replace-fail 'PROMPT_PADDING = " " * 501' 'PROMPT_PADDING = ""' \
      --replace-fail '"--single-turn",' '"--single-turn", "--no-display-prompt",' \
      --replace-fail 'content = content.strip()' 'content = content.strip("\x08 \t\n\r")' \
      --replace-fail 'process = None' 'comfy.model_management.unload_all_models(); comfy.model_management.soft_empty_cache(); process = None'
  '';
}
