{ fetchFromBittorrent
, runCommand
, unzip
, dosbox-x
, xvfb-run
, x11vnc
, tesseract
, expect
, vncdo
, writeScript
, writeShellScript
, writeText
, callPackage
}:
{ ... }:
let
  msdos622 = fetchFromBittorrent {
    url = "https://archive.org/download/MS_DOS_6.22_MICROSOFT/MS_DOS_6.22_MICROSOFT_archive.torrent";
    hash = "sha256-B88pYYF9TzVscXqBwql2vSPyp2Yf2pxJ75ywFjUn1RY=";
  };

  dosboxConf = writeText "dosbox.conf" ''
    [cpu]
    turbo=on
    stop turbo on key = false

    [autoexec]
    imgmount 2 disk.img -size 512,63,16,507 -fs none
    boot "msdos/MS DOS 6.22/Disk 1.img" "msdos/MS DOS 6.22/Disk 2.img" "msdos/MS DOS 6.22/Disk 3.img"
  '';

  tesseractScript = writeShellScript "tesseractScript" ''
    export OMP_THREAD_LIMIT=1
    cd $(mktemp -d)
    TEXT=""
    while true
    do
      sleep 3
      ${vncdo}/bin/vncdo -s 127.0.0.1::5900 capture cap.png
      NEW_TEXT="$(${tesseract}/bin/tesseract cap.png stdout 2>/dev/null)"
      if [ "$TEXT" != "$NEW_TEXT" ]; then
        echo "$NEW_TEXT"
        TEXT="$NEW_TEXT"
      fi
    done
  '';

  expectScript = let
    vncdoWrapper = writeScript "vncdoWrapper" ''
      sleep 3
      ${vncdo}/bin/vncdo --force-caps -s 127.0.0.1::5900 "$@"
    '';
  in writeScript "expect.sh" ''
    #!${expect}/bin/expect -f
    set debug 5
    set timeout -1
    spawn ${tesseractScript}
    expect "To continue Setup, press ENTER."
    exec ${vncdoWrapper} move 800 0
    exec ${vncdoWrapper} key enter
    expect "unallocated disk space"
    exec ${vncdoWrapper} key enter
    expect "Setup will restart your computer"
    exec ${vncdoWrapper} key enter
    expect "The settings are correct"
    exec ${vncdoWrapper} key enter
    expect "Setup will place your MS-DOS files in the following"
    exec ${vncdoWrapper} key enter
    expect "Disk #2"
    exec ${vncdoWrapper} key f12-o pause 3 key enter
    expect "Disk #3"
    exec ${vncdoWrapper} key f12-o pause 3 key enter
    expect "Remove disks"
    exec ${vncdoWrapper} key enter
    expect "MS-DOS Setup Complete"
    exec ${vncdoWrapper} key enter
    expect "Microsoft MS-DOS 6.22 Setup"
    send_user "\n### OMG DID IT WORK???!!!! ###\n"
    exit 0
  '';
in runCommand "msdos622.img" {
  buildInputs = [ unzip dosbox-x xvfb-run x11vnc ];
  passthru = rec {
    makeRunScript = callPackage ./run.nix;
    runScript = makeRunScript {};
  };
  # set __impure = true; for debugging
  # __impure = true;
} ''
  echo ${msdos622}
  mkdir win
  mkdir msdos
  unzip '${msdos622}/MS DOS 6.22.zip' -d msdos
  dd if=/dev/zero of=disk.img count=8192 bs=31941
  xvfb-run -l -s ":99 -auth /tmp/xvfb.auth -ac -screen 0 800x600x24" dosbox-x -conf ${dosboxConf} || true &
  dosboxPID=$!
  DISPLAY=:99 XAUTHORITY=/tmp/xvfb.auth x11vnc -many -shared -display :99 >/dev/null 2>&1 &
  ${expectScript} &
  wait $!
  kill $dosboxPID
  mv disk.img $out
''
