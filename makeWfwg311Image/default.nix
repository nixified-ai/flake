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
, callPackage
}:
{ dosPostInstall ? "", ... }:
let
  msdos622 = makeMsDos622Image {};
  wfwg311-installer = fetchFromBittorrent {
    url = "https://archive.org/download/ms-wfw311-12mb-retail/ms-wfw311-12mb-retail_archive.torrent";
    hash = "sha256-7ZYP9DegRTUi4sRzkKO8t0kxxV1gVMnD9jVEQFp3TYc=";
  };
  dosboxConf = writeText "dosbox.conf" ''
    [cpu]
    turbo=on
    stop turbo on key = false

    [autoexec]
    imgmount C msdos622.img
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
      sleep 3
      ${vncdo}/bin/vncdo --force-caps -s 127.0.0.1::5900 "$@"
    '';
  in writeScript "expect.sh"
  ''
    #!${expect}/bin/expect -f
    set debug 5
    set timeout -1
    spawn ${tesseractScript}
    expect "CiN"
    exec ${vncdoWrapper} type "A:" key enter pause 3 type "SETUP.EXE" pause 3 key enter
    expect "Workgroups 3.11 Setup"
    exec ${vncdoWrapper} key enter
    expect "Express Setup"
    exec ${vncdoWrapper} key enter
    expect "Disk 2"
    exec ${vncdoWrapper} key f12-o pause 3 key enter
    expect "Windows Setup"
    exec ${vncdoWrapper} type "Eelco Dolstra" pause 3 key alt-o pause 3 key alt-o
    expect "Disk 3"
    exec ${vncdoWrapper} key f12-o pause 3 key enter
    expect "Disk 4"
    exec ${vncdoWrapper} key f12-o pause 3 key enter
    expect "Disk §"
    exec ${vncdoWrapper} key f12-o pause 3 key enter
    expect "Disk 6"
    exec ${vncdoWrapper} key f12-o pause 3 key enter
    expect "Disk 7"
    exec ${vncdoWrapper} key f12-o pause 3 key enter
    expect "Disk 8"
    exec ${vncdoWrapper} key f12-o pause 3 key enter
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
  installedImage = runCommand "wfwg311.img" {
    # set __impure = true; for debugging
    # __impure = true;
    buildInputs = [ unzip dosbox-x xvfb-run x11vnc ];
    passthru = rec {
      makeRunScript = callPackage ./run.nix;
      runScript = makeRunScript {};
    };
  } ''
    echo "wfwg311-installer src: ${wfwg311-installer}"
    mkdir wfwg311
    cp -r --no-preserve=mode ${wfwg311-installer}/*.IMG wfwg311
    ls -lah wfwg311
    cp --no-preserve=mode ${msdos622} ./msdos622.img
    xvfb-run -l -s ":99 -auth /tmp/xvfb.auth -ac -screen 0 800x600x24" dosbox-x -conf ${dosboxConf} || true &
    dosboxPID=$!
    DISPLAY=:99 XAUTHORITY=/tmp/xvfb.auth x11vnc -many -shared -display :99 >/dev/null 2>&1 &
    ${expectScript} &
    wait $!
    kill $dosboxPID
    cp ./msdos622.img $out
  '';
  postInstalledImage = let
    dosboxConf-postInstall = writeText "dosbox.conf" ''
      [cpu]
      turbo=on
      stop turbo on key = false

      [autoexec]
      imgmount C wfwg311.img
      ${dosPostInstall}
      exit
    '';
  in runCommand "wfwg311.img" {
    buildInputs = [ dosbox-x ];
    inherit (installedImage) passthru;
  } ''
    cp --no-preserve=mode ${installedImage} ./wfwg311.img
    SDL_VIDEODRIVER=dummy dosbox-x -conf ${dosboxConf-postInstall}
    mv wfwg311.img $out
  '';
in if (dosPostInstall != "") then postInstalledImage else installedImage
