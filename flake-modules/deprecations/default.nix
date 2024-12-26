{
  perSystem = { ... }: let
    deprecationFunding = project: vendor: lastCommit: builtins.throw ''


             ${project} has been dropped from nixified.ai due to lack of
             funding, contribution and maintainability. Please consider
             sponsoring at https://github.com/sponsors/nixified-ai so it may be
             reintroduced

             If you would like to reproduce the last available version of
             ${project} with nixified.ai, then run:

             nix run github:nixified.ai/flake/${lastCommit}#${project}-${vendor}
    '';
  in {
    legacyPackages = {
      invokeai-amd = deprecationFunding "invokeai" "amd" "2aeb76f52f72c7a242f20e9bc47cfaa2ed65915d";
      invokeai-nvidia = deprecationFunding "invokeai" "nvidia" "2aeb76f52f72c7a242f20e9bc47cfaa2ed65915d";
      textgen-amd = deprecationFunding "textgen" "amd" "2aeb76f52f72c7a242f20e9bc47cfaa2ed65915d";
      textgen-nvidia = deprecationFunding "textgen" "nvidia" "2aeb76f52f72c7a242f20e9bc47cfaa2ed65915d";
      koboldai = builtins.throw ''


               koboldai has been dropped from nixified.ai due to lack of upstream development,
               try textgen instead which is better maintained. If you would like to use the last
               available version of koboldai with nixified.ai, then run:

               nix run github:nixified.ai/flake/0c58f8cba3fb42c54f2a7bf9bd45ee4cbc9f2477#koboldai
      '';
    };
  };
}
