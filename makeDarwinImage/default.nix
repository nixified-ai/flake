{ fetchurl, writeScript, writeShellScript, writeShellScriptBin, runCommand, lib, vncdo, dmg2img, cdrkit, parted, qemu_kvm, coreutils, python311, imagemagick, tesseract, expect }:
{ diskSizeBytes ? 50000000000 }:
let
  installAssistant-fetched = fetchurl {
    url = "https://swcdn.apple.com/content/downloads/28/01/042-55926-A_7GZJNO2M4I/asqcyheggme9rflzb3z3pr6vbp0gxyk2eh/InstallAssistant.pkg";
    sha256 = "74c1893ef0df8ec39875d8475aa614de0395d556a531a161538a13f8bb17ac42";
  };
  installAssistant-iso = runCommand "InstallAssistant.iso" { buildInputs = [ cdrkit ]; } ''
    cp --no-preserve=mode ${./OSX-KVM/scripts/run_offline.sh} ./run_offline.sh
    cp --no-preserve=mode ${installAssistant-fetched} ./InstallAssistant.pkg
    mkisofs -allow-limited-size -l -J -r -iso-level 3 -V InstallAssistant -o $out ./InstallAssistant.pkg ./run_offline.sh
  '';

  baseSystem-img = runCommand "BaseSystem.img" { nativeBuildInputs = [ python311 dmg2img qemu_kvm ];
    outputHashAlgo = "sha256";
    outputHash = "sha256-Qy9Whu8pqHo+m6wHnCIqURAR53LYQKc0r87g9eHgnS4=";
    outputHashMode = "recursive";
  } ''
    cp --no-preserve=mode ${./OSX-KVM}/fetch-macOS-v2.py .
    chmod +x ./fetch-macOS-v2.py
    patchShebangs ./fetch-macOS-v2.py
    substituteInPlace ./fetch-macOS-v2.py --replace 'Mac-7BA5B2D9E42DDD94' 'Mac-BE088AF8C5EB4FA2'
    ./fetch-macOS-v2.py --shortname ventura
    dmg2img -i BaseSystem.dmg $out
  '';

  tesseractScript = writeShellScript "tesseractScript" ''
    export OMP_THREAD_LIMIT=1
    cd $(mktemp -d)
    TEXT=""
    while true
    do
      sleep 5
      ${vncdo}/bin/vncdo -s 127.0.0.1::5901 rcapture cap.png 0 0 1920 1080
      NEW_TEXT="$(${tesseract}/bin/tesseract cap.png stdout 2>/dev/null)"
      if [ "$TEXT" != "$NEW_TEXT" ]; then
        echo "$NEW_TEXT"
        TEXT="$NEW_TEXT"
      fi
    done
  '';

  expectScript = let
    vncdoWrapper = writeScript "vncdoWrapper" ''
      echo Sending VNC inputs for $1
      sleep 5
      ${vncdo}/bin/vncdo --force-caps -s 127.0.0.1::5901 "''${@:2}"
    '';
  in writeScript "expect.sh"
  ''
    #!${expect}/bin/expect -f
    set debug 2
    set timeout -1
    spawn ${tesseractScript}
    expect "macOS Base"
    exec ${vncdoWrapper} "Boot Stage 1" key enter
    expect "Continue"
    exec ${vncdoWrapper} "Open terminal" key shift-super-t
    expect "Terminal"
    expect "80x24"
    exec ${vncdoWrapper} "Execute run_offline.sh" type "sh /Volumes/InstallAssistant/run_offline.sh" key enter
    expect "Continue"
    exec ${vncdoWrapper} "Welcome to macOS" move 995 720 click 1
    expect "Disagree"
    exec ${vncdoWrapper} "Agree to EULA" move 995 720 click 1
    expect "have read and agree to the"
    exec ${vncdoWrapper} "Really Agree to EULA" move 1000 525 click 1
    expect "Select the disk where you want to install macOS"
    exec ${vncdoWrapper} "Select macOS as install disk" move 780 550 click 1
    expect "Continue"
    exec ${vncdoWrapper} "Continue" move 1000 710 click 1
    expect "macOS Base"
    exec ${vncdoWrapper} "Boot Stage 2" key enter
    expect "macOS Base"
    exec ${vncdoWrapper} "Boot Stage 3" key enter
    expect "macOS Base"
    exec ${vncdoWrapper} "Boot Stage 4" key enter
    expect "macOS Base"
    exec ${vncdoWrapper} "Boot Stage 5" key enter
    expect "Select Your Country or Region"
    exec ${vncdoWrapper} "Select Your Country or Region" type "united states" pause 5 key shift-tab pause 5 key space
    expect "Written and Spoken Languages"
    exec ${vncdoWrapper} "Written and Spoken Languages" key shift-tab pause 5 key space
    expect "Accessibility"
    exec ${vncdoWrapper} "Accessibility" key shift-tab pause 5 key space
    expect "How Do You Connect?"
    exec ${vncdoWrapper} "How Do You Connect?" move 815 480 click 1 pause 5 move 1330 820 click 1
    expect "Your Mac isn't connected to"
    exec ${vncdoWrapper} "Your Mac isn't connected to" move 1020 640 click 1
    expect "Data & Privacy"
    exec ${vncdoWrapper} "Data & Privacy" key shift-tab pause 5 key space
    expect "Migration Assistant"
    exec ${vncdoWrapper} "Migration Assistant" key tab pause 5 key tab pause 5 key tab pause 5 key space

    ## Not needed when offline
    # expect "Sign In with Your Apple ID"
    # exec ${vncdoWrapper} "Sign in with Your Apple ID" key shift-tab pause 5 key shift-tab pause 5 key space
    # expect "Are you sure you want to skip"
    # exec ${vncdoWrapper} "Are you sure you want to skip signing in with an Apple ID?" key tab pause 5 key space
    # expect "Terms and Conditions"

    exec ${vncdoWrapper} "Terms and Conditions" key shift-tab pause 5 key space
    expect "Software License"
    exec ${vncdoWrapper} "I have read and agree to the macOS Software License Agreement." key tab pause 5 key space
    expect "Create a Computer Account"
    exec ${vncdoWrapper} "Create a Computer Account" pause 5 type "admin" pause 5 key tab pause 5 type "admin" pause 5 key tab pause 5 type "admin" pause 5 key tab pause 5 type "admin" pause 5 key tab pause 5 key tab pause 5 key tab pause 5 key space
    expect "Enable Location Services"
    exec ${vncdoWrapper} "Enable Location Services" key shift-tab pause 5 key space
    expect "Are you sure you don't want to"
    exec ${vncdoWrapper} "Are you sure you don't want to use Location Services?" key tab pause 5 key space
    expect "Select Your Time Zone"
    exec ${vncdoWrapper} "Select Your Time Zone" key tab pause 5 type UTC pause 5 key enter pause 5 key shift-tab pause 5 key space
    expect "Analytics"
    exec ${vncdoWrapper} "Analytics" key tab pause 5 key space pause 5 key shift-tab pause 5 key space
    expect "Screen Time"
    exec ${vncdoWrapper} "Screen Time" key tab pause 5 key space
    expect "Choose Your Look"
    exec ${vncdoWrapper} "Choose Your Look" key shift-tab pause 5 key space
    expect "Keyboard Setup Assistant"
    exec ${vncdoWrapper} "Quit Keyboard Setup Assistant" key super-q pause 5 move 0 0 click 1
    expect "Shut Down"
    exec ${vncdoWrapper} "Quit Keyboard Setup Assistant" key up pause 5 key up pause 5 key up pause 5 key enter pause 5 key enter
    send_user "\n### OMG DID IT WORK???!!!! ###\n"
    exit 0
  '';

  runInVm = runCommand "mac_hdd_ng.img" {
    buildInputs = [ parted qemu_kvm ];
    # __impure = true; # set __impure = true; if debugging and want to connect via vnc
  } ''
    cp -v -r --no-preserve=mode ${./OSX-KVM} ./OSX-KVM
    cd ./OSX-KVM
    qemu-img create -f qcow2 -b ${baseSystem-img} -F raw ./BaseSystem.qcow2
    qemu-img create -f qcow2 -b ${installAssistant-iso} -F raw ./InstallAssistant.qcow2
    qemu-img create -f qcow2 ./mac_hdd_ng.img ${toString diskSizeBytes} # 50 Gigabytes, not Gibibytes
    sh ./OpenCore-Boot.sh &
    openCoreBootPID=$!
    ${expectScript} &
    wait $openCoreBootPID
    mv mac_hdd_ng.img $out
  '';
in runInVm
