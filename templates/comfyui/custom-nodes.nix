{
  stdenv,
  fetchFromGitHub,
  python3Packages,
  customNodes,
  models,
}: {
  inherit (customNodes) comfyui-gguf;

  # random, useless example node
  good-node = stdenv.mkDerivation {
    pname = "good-node";
    version = "0.0.0";
    src = fetchFromGitHub {
      owner = "Suzie1";
      repo = "ComfyUI_Guide_To_Making_Custom_Nodes";
      rev = "9d64214cfd53a89769541c645f921f0acb0c38f1";
      sha256 = "sha256-ol9Ep+K/LOaDJxWEBP+tENWCaEw8EnzlEEDtaPurmBE=";
    };
    installPhase = ''
      runHook preInstall
      mkdir -p $out/
      cp -r $src/* $out/
      runHook postInstall
    '';
    passthru.dependencies = {
      # python dependencies
      # pkgs = with python3Packages; [];
      # nodes can depend on models
      # models = {inherit (models) good-model;};
    };
  };
}
