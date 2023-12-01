{ writeShellScriptBin
, writeText
, lib
, dosbox-x
, makeWfwg311Image
, extraDosboxFlags ? []
, diskImage ? makeWfwg311Image {
    dosPostInstall = ''
      c:
      echo win >> AUTOEXEC.BAT
    '';
  }
}:
let
  dosboxConf = writeText "dosbox.conf" ''
    [autoexec]
    imgmount C wfwg311.img
    boot -l C
  '';
in
writeShellScriptBin "run-wfwg311.sh" ''
  args=(
    -conf ${dosboxConf}
    ${lib.concatStringsSep " " extraDosboxFlags}
    "$@"
  )

  if [ ! -f wfwg311.img ]; then
    echo "wfwg311.img not found, making disk image ./wfwg311.img"
    cp --no-preserve=mode ${diskImage} ./wfwg311.img
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

