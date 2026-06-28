{
  lib,
  fetchFromGitHub,
  fetchFromGitLab,
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
        "GitLab"
        "Git"
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
      repo =
        if repoType == "GitLab" then
          lib.last (lib.splitString "/" source.repository.repo_path)
        else if repoType == "GitHub" then
          source.repository.repo
        else
          let
            urlParts = lib.splitString "/" source.repository.url;
          in
          lib.removeSuffix ".git" (lib.last urlParts);
      owner =
        if repoType == "GitLab" then
          lib.head (lib.splitString "/" source.repository.repo_path)
        else if repoType == "GitHub" then
          source.repository.owner
        else
          "unknown";
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
      src =
        if repoType == "GitLab" then
          fetchFromGitLab {
            inherit owner repo;
            sha256 = source.hash;
            rev = source.revision;
          }
        else if repoType == "GitHub" then
          fetchFromGitHub {
            inherit owner repo;
            sha256 = source.hash;
            rev = source.revision;
            fetchSubmodules = source.submodules or false;
          }
        else
          builtins.fetchGit {
            url = source.repository.url;
            rev = source.revision;
            submodules = source.submodules or false;
          };
    };

  nodePropsFromManagerNode =
    node:
    let
      installType = node.install_type or "git-clone";
      url =
        if installType == "git-clone" then
          if builtins.isList node.files then builtins.head node.files else node.files
        else if installType == "copy" then
          if builtins.isList node.files then builtins.head node.files else node.files
        else
          node.reference or node.files;

      repo =
        let
          matchGithub = builtins.match ".*github\\.com/([^/]+)/([^/.]+)(\\.git)?/?.*" url;
          matchGitlab = builtins.match ".*gitlab\\.com/([^/]+)/([^/.]+)(\\.git)?/?.*" url;
          matchOther = builtins.match ".*/([^/.]+)(\\.git)?/?.*" url;
        in
        if matchGithub != null then
          builtins.elemAt matchGithub 1
        else if matchGitlab != null then
          builtins.elemAt matchGitlab 1
        else if matchOther != null then
          builtins.elemAt matchOther 0
        else
          "unknown-node";

      pname = makePname repo;

      src =
        if installType == "git-clone" then
          builtins.fetchGit {
            inherit url;
            submodules = true;
          }
        else if installType == "copy" then
          builtins.fetchurl { inherit url; }
        else
          builtins.fetchGit {
            inherit url;
            submodules = true;
          };
    in
    {
      inherit pname;
      version = "latest";
      inherit src;
    }
    // (lib.optionalAttrs (installType == "copy") {
      dontUnpack = true;
      installPhase = ''
        runHook preInstall
        mkdir -p $out/${python3Packages.python.sitePackages}/custom_nodes/
        cp $src $out/${python3Packages.python.sitePackages}/custom_nodes/$(basename ${url})
        runHook postInstall
      '';
    });
}
