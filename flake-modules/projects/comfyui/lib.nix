{
  python3Packages,
  stdenv,
}:
{
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
}
