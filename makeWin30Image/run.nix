{ writeShellScriptBin
, writeText
, runCommand
, lib
, dosbox-x
, makeWin30Image
, extraDosboxFlags ? []
, diskImage ? (makeWin30Image {})
}:
let
  dosboxConf = writeText "dosbox.conf" ''
    [autoexec]
    imgmount c win30.img -size 512,63,16,507 -t hdd -fs fat
    boot -l c
  '';
  dosboxConf-stage2 = writeText "dosbox.conf" ''
    [cpu]
    turbo=on
    stop turbo on key = false

    [autoexec]
    imgmount c win30.img -size 512,63,16,507 -t hdd -fs fat
    c:
    echo win >> AUTOEXEC.BAT
    exit
  '';
  diskImage2 = runCommand "win30.img" {
    buildInputs = [ dosbox-x ];
  } ''
    cp --no-preserve=mode ${diskImage} ./win30.img
    SDL_VIDEODRIVER=dummy dosbox-x -conf ${dosboxConf-stage2}
    mv win30.img $out
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
    cp --no-preserve=mode ${diskImage2} ./win30.img
  fi

  run_dosbox() {
    ${dosbox-x}/bin/dosbox-x "''${args[@]}"
  }

  run_dosbox

  if [ $? -ne 0 ]; then
    echo "Dosbox crashed. Re-running with SDL_VIDEODRIVER=x11."
    SDL_VIDEODRIVER=x11 run_dosbox
  fi
''

