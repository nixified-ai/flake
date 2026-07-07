{ pkgs }:
{
  patches = [ ./fix-folder-registry.patch ./fix-llama-binary.patch ];
  postPatch = ''
    substituteInPlace llama_binary.py \
      --replace-fail "@llama-cli@" "${pkgs.llama-cpp}/bin/llama-cli"
  '';
}
