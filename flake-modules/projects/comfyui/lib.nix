{
  lib,
  fetchFromGitHub,
  python3Packages,
  stdenv,
}:
rec {
  mkComfyUICustomNode =
    let
      install =
        name:
        let
          installDir = "$out/${python3Packages.python.sitePackages}/custom_nodes/${name}";
        in
        ''
          mkdir -p ${installDir}
          shopt -s dotglob
          shopt -s extglob
          cp -r ./!($out|$src) ${installDir}
        '';
    in
    args:
    (if args ? "overrideAttrs" then args else stdenv.mkDerivation args).overrideAttrs (
      finalAttrs: previousAttrs: {
        installPhase = ''
          runHook preInstall
          mkdir -p $out/
          ${install finalAttrs.name or finalAttrs.pname}
          runHook postInstall
        '';
      }
    );
  sanitizeName = x: lib.replaceStrings [ "_" ] [ "-" ] (lib.toLower x);
  makePname =
    repo:
    let
      sanitized = sanitizeName repo;
      prefix = "comfyui-";
    in
    if lib.hasPrefix prefix sanitized then sanitized else "${prefix}${sanitized}"

  ;
  nodePropsFromNpinSource =
    let
      supportedTypes = [
        "Git"
        "GitRelease"
      ];
      supportedRepoTypes = [
        "GitHub"
      ];
    in
    { type, ... }@source:
    assert lib.assertMsg (lib.elem type supportedTypes) ''
      Unsuported npins source type: ${toString type}.
      Supported types: ${lib.concatStringsSep ", " supportedTypes}
    '';
    let
      repoType = source.repository.type;
    in
    assert lib.assertMsg (lib.elem repoType supportedRepoTypes) ''
      Unsuported npins source repository.type: ${toString repoType}.
      Supported types: ${lib.concatStringsSep ", " supportedRepoTypes}
    '';
    let
      inherit (source.repository) repo;
      version =
        if source ? version then
          let
            versionPrefix = if (source.release_prefix or null != null) then source.release_prefix else "v";
          in
          lib.removePrefix versionPrefix source.version
        else
          "git-${lib.substring 0 7 source.revision}";
    in
    {
      inherit version;
      pname = makePname repo;
      src = fetchFromGitHub {
        inherit repo;
        owner = source.repository.owner;
        sha256 = source.hash;
        rev = source.revision;
      };
    };
}
