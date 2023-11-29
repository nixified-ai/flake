{ writeShellScriptBin
, writeText
, fetchFromGitHub
, lib
, dosbox-x
, makeWin30Image
, extraDosboxFlags ? []
, diskImage ? (makeWin30Image {})
}:
let
  dosbox-x-fix = dosbox-x.overrideAttrs {
    src = fetchFromGitHub {
      owner = "joncampbell123";
      repo = "dosbox-x";
      rev = "d2febc9ad28c7e3a4e4c3f52c8159d693078679b";
      hash = "sha256-O+qpdkHOHSYG2BSlNxeTW+tMRUxrnQW/iEFx6DIGOik=";
    };
  };
  dosboxConf = writeText "dosbox.conf" ''
    [autoexec]
    imgmount C win30.img -size 512,63,16,507 -t hdd -fs fat
    boot -l C
  '';
in
writeShellScriptBin "run-win30.sh" ''
  args=(
    -conf ${dosboxConf}
    ${lib.concatStringsSep " " extraDosboxFlags}
    "$@"
  )

  if [ ! -f win30.img ]; then
    echo "win30.img not found, making disk image ./win30.img"
    cp --no-preserve=mode ${diskImage} ./win30.img
  fi

  run_dosbox() {
    ${dosbox-x-fix}/bin/dosbox-x "''${args[@]}"
  }

  run_dosbox

  if [ $? -ne 0 ]; then
    echo "Dosbox crashed. Re-running with SDL_VIDEODRIVER=x11."
    SDL_VIDEODRIVER=x11 run_dosbox
  fi
''

