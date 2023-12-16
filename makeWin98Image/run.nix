{ writeShellScriptBin, writeText, lib, dosbox-x, makeWin98Image
, extraDosboxFlags ? [ ], diskImage ? makeWin98Image {
  dosPostInstall = ''
    c:
    echo win >> AUTOEXEC.BAT
  '';
} }:
let
  dosboxConf = writeText "dosbox.conf" ''
    [sdl]
    autolock = true

    [autoexec]
    imgmount C win98.img
    boot -l C
  '';
in writeShellScriptBin "run-win98.sh" ''
  args=(
    -conf ${dosboxConf}
    ${lib.concatStringsSep " " extraDosboxFlags}
    "$@"
  )

  if [ ! -f win98.img ]; then
    echo "win98.img not found, making disk image ./win98.img"
    cp --no-preserve=mode ${diskImage} ./win98.img
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

