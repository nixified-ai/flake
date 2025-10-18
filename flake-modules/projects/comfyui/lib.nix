{
  python3Packages,
  stdenv,
}:
{
  mkComfyUICustomNode =
    let
      install = name: ''
        mkdir -p $out/${python3Packages.python.sitePackages}/custom_nodes/${name}
        shopt -s dotglob
        shopt -s extglob
        cp -r ./!($out|$src) $out/${python3Packages.python.sitePackages}/custom_nodes/${name}
      '';
    in
    args:
    stdenv.mkDerivation (
      {
        installPhase = ''
          runHook preInstall
          mkdir -p $out/
          ${install args.name or args.pname}
          runHook postInstall
        '';
      }
      // args
    );
}
