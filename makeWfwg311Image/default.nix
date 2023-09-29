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
, makeMsDos622Image
, fetchFromGitHub
}:
{ ... }:
let
  dosbox-x-fix = dosbox-x.overrideAttrs {
    src = fetchFromGitHub {
      owner = "joncampbell123";
      repo = "dosbox-x";
      rev = "d2febc9ad28c7e3a4e4c3f52c8159d693078679b";
      hash = "sha256-O+qpdkHOHSYG2BSlNxeTW+tMRUxrnQW/iEFx6DIGOik=";
    };
  };
  msDos622 = makeMsDos622Image {};

  wfwg311 = fetchFromBittorrent {
    url = "https://archive.org/download/ms-wfw311-12mb-retail/ms-wfw311-12mb-retail_archive.torrent";
    hash = "sha256-7ZYP9DegRTUi4sRzkKO8t0kxxV1gVMnD9jVEQFp3TYc=";
  };

  dosboxConf = writeText "dosbox.conf" ''
    [cpu]
    turbo=on
    stop turbo on key = false

    [autoexec]
    imgmount C msdos622.img -size 512,63,16,507 -t hdd -fs fat
    imgmount A -t floppy wfwg311/DISK01.IMG wfwg311/DISK02.IMG wfwg311/DISK03.IMG wfwg311/DISK04.IMG wfwg311/DISK05.IMG wfwg311/DISK06.IMG wfwg311/DISK07.IMG wfwg311/DISK08.IMG wfwg311/DISK09.IMG wfwg311/DISK10.IMG

    boot -l C
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
      ${vncdo}/bin/vncdo --force-caps -s 127.0.0.1::5900 "$@"
    '';
  in writeScript "expect.sh"
  ''
    #!${expect}/bin/expect -f
    set debug 5
    set timeout -1
    spawn ${tesseractScript}
    expect "CiN"
    exec ${vncdoWrapper} type "A:" key enter pause 1 type "SETUP.EXE" pause 1 key enter
    expect "Workgroups 3.11 Setup"
    exec ${vncdoWrapper} key enter
    expect "Express Setup"
    exec ${vncdoWrapper} key enter
    expect "Disk 2"
    exec ${vncdoWrapper} key f12-o pause 1 key enter
    expect "Windows Setup"
    exec ${vncdoWrapper} type "Eelco Dolstra" pause 1 key alt-o pause 1 key alt-o
    expect "Disk 3"
    exec ${vncdoWrapper} key f12-o pause 1 key enter
    expect "Disk 4"
    exec ${vncdoWrapper} key f12-o pause 1 key enter
    expect "Disk §"
    exec ${vncdoWrapper} key f12-o pause 1 key enter
    expect "Disk 6"
    exec ${vncdoWrapper} key f12-o pause 1 key enter
    expect "Disk 7"
    exec ${vncdoWrapper} key f12-o pause 1 key enter
    expect "Disk 8"
    exec ${vncdoWrapper} key f12-o pause 1 key enter
    expect "Printer Installation"
    exec ${vncdoWrapper} key enter
    expect "Network Setup"
    exec ${vncdoWrapper} key alt-o
    expect "Set Up Applications"
    exec ${vncdoWrapper} key enter
    expect "short tutorial"
    exec ${vncdoWrapper} key alt-s
    expect "Exit Windows Setup"
    exec ${vncdoWrapper} key alt-r
    expect "CiN"
    send_user "\n### OMG DID IT WORK???!!!! ###\n"
    exit 0
  '';

in
runCommand "wfwg311.img" { buildInputs = [ unzip dosbox-x-fix xvfb-run x11vnc ];
  # set __impure = true; for debugging
  # __impure = true;
    } ''
  echo ${wfwg311}
  mkdir wfwg311
  cp -r --no-preserve=mode ${wfwg311}/*.IMG wfwg311
  ls -lah wfwg311
  dd if=/dev/zero of=disk.img count=8192 bs=31941
  cp --no-preserve=mode ${msDos622} ./msdos622.img

  xvfb-run -l -s ":99 -auth /tmp/xvfb.auth -ac -screen 0 800x600x24" dosbox-x -conf ${dosboxConf} || true &
  dosboxPID=$!
  DISPLAY=:99 XAUTHORITY=/tmp/xvfb.auth x11vnc -many -shared -display :99 >/dev/null 2>&1 &
  ${expectScript} &
  wait $!
  kill $dosboxPID
  mv ./msdos622.img $out
''
