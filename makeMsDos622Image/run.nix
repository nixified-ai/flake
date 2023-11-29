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

  ${dosbox-x}/bin/dosbox-x "''${args[@]}"
''
