{ writeShellScriptBin
, writeText
, lib
, dosbox-x
, makeMsDos622Image
, extraDosboxFlags ? []
, diskImage ? (makeMsDos622Image {})
}:
let
  dosboxConf = writeText "dosbox.conf" ''
    [autoexec]
    imgmount 2 msdos622.img -fs none
    boot -l c
  '';
in
writeShellScriptBin "run-msdos622.sh" ''
  args=(
    -conf ${dosboxConf}
    ${lib.concatStringsSep " " extraDosboxFlags}
    "$@"
  )

  if [ ! -f msdos622.img ]; then
    echo "msdos622.img not found, making disk image ./msdos622.img"
    cp --no-preserve=mode ${diskImage} ./msdos622.img
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
