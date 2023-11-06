{ fetchurl, writeScript, writeShellScript, writeShellScriptBin, runCommand, lib, vncdo, dmg2img, cdrkit, parted, qemu_kvm, coreutils, python311, imagemagick, tesseract, expect, socat, ruby }:
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
      sleep 10
      ${vncdo}/bin/vncdo -s 127.0.0.1::5901 rcapture cap.png 0 0 1920 1080
      NEW_TEXT="$(${tesseract}/bin/tesseract cap.png stdout 2>/dev/null)"
      if [ "$TEXT" != "$NEW_TEXT" ]; then
        echo "$NEW_TEXT"
        TEXT="$NEW_TEXT"
      fi
      mv cap.png cap-$(date +%Y-%m-%dT%H:%M:%S).png
    done
  '';

  expectScript = let
    qemuSendMouse = writeScript "qemuSendMouse" ''
      echo Sending QEMU inputs for $1
      sleep 10
      echo mouse_move $1 $2 | ${socat}/bin/socat - unix-connect:qemu-monitor-socket
      echo mouse_button 1 | ${socat}/bin/socat - unix-connect:qemu-monitor-socket
      echo mouse_button 0 | ${socat}/bin/socat - unix-connect:qemu-monitor-socket
    '';
    qemuSendKeys = writeScript "qemuSendKeys" ''
      input="$1"
      cleaned_input=$(echo "$input" | sed 's/\\//g')
      echo Sending QEMU inputs for "$cleaned_input" >> qemuSendKeysLog
      sleep 10
      ${ruby}/bin/ruby ${./sendkeys} "$cleaned_input" | ${socat}/bin/socat - unix-connect:qemu-monitor-socket
    '';
    qemuAddMouse = writeScript "qemuAddMouse" ''
      sleep 10
      echo -e "device_add usb-tablet,id=mouse1" | ${socat}/bin/socat - unix-connect:qemu-monitor-socket
    '';
    vncdoWrapper = writeScript "vncdoWrapper" ''
      echo Sending VNC inputs for $1
      sleep 10
      ${vncdo}/bin/vncdo --force-caps -s 127.0.0.1::5901 "''${@:2}"
    '';
  in writeScript "expect.sh"
  ''
    #!${expect}/bin/expect -f
    set debug 2
    set log_user 1
    set timeout -1
    exp_internal 1

    spawn ${tesseractScript}
    expect "Continue"
    exec ${qemuSendKeys} "\\<shift-meta_l-t>"
    expect "Terminal"
    expect "80x24"
    exec ${qemuSendKeys} "sh /Volumes/InstallAssistant/run_offline.sh<kp_enter>"

    # Welcome to macOS
    expect "Continue"
    exec ${qemuSendMouse} 995 720

    # Agree to EULA
    expect "Disagree"
    exec ${qemuSendMouse} 995 720

    # Really Agree to EULA
    expect "have read and agree to the"
    exec ${qemuSendMouse} 1000 525

    # Select macOS as install disk
    expect "Select the disk where you want to install macOS"
    exec ${qemuSendMouse} 780 550

    # Continue
    expect "Continue"
    exec ${qemuSendMouse} 1000 710

    # "Select Your Country or Region"
    expect "Select Your Country or Region"
    exec ${qemuSendKeys} "united states<delay><shift-tab><delay><spc>"

    # "Written and Spoken Languages"
    expect "Written and Spoken Languages"
    exec ${qemuSendKeys} "\\\\\<shift-tab><delay><spc>"

    # "Accessibility"
    expect "Accessibility"
    exec ${qemuSendKeys} "\\\\\<shift-tab><delay><spc>"

    # "How Do You Connect?"
    expect "How Do You Connect?"
    exec ${qemuSendMouse} 815 480
    exec sleep 10
    exec ${qemuSendMouse} 1330 820

    # "Your Mac isn't connected to the internet"
    expect "Your Mac isn't connected to"
    exec ${qemuSendMouse} 1020 640

    # "Data & Privacy"
    expect "Data & Privacy"
    exec ${qemuSendKeys} "\\\\\<shift-tab><delay><spc>"

    # "Migration Assistant"
    expect "Migration Assistant"
    exec ${qemuSendKeys} "\\\\\<tab><delay><tab><delay><tab><delay><spc>"

    ## Not needed when offline
    # expect "Sign In with Your Apple ID"
    # exec ${vncdoWrapper} "Sign in with Your Apple ID" key shift-tab pause 10 key shift-tab pause 10 key space
    # expect "Are you sure you want to skip"
    # exec ${vncdoWrapper} "Are you sure you want to skip signing in with an Apple ID?" key tab pause 10 key space
    # expect "Terms and Conditions"

    # "Terms and Conditions"
    expect "Terms and Conditions"
    exec ${qemuSendKeys} "\\\\\<shift-tab><delay><spc>"

    # "I have read and agree to the macOS Software License Agreement."
    expect "Software License"
    exec ${qemuSendKeys} "\\\\\<tab><delay><spc>"

    # "Create a Computer Account"
    expect "Create a Computer Account"
    exec ${qemuSendKeys} "admin<delay><tab><delay>admin<delay><tab><delay>admin<delay><tab><delay>admin<delay><tab><delay><tab><delay><tab><delay><spc>"

    # "Enable Location Services"
    expect "Enable Location Services"
    exec ${qemuSendKeys} "\\\\\<shift-tab><delay><spc>"

    # "Are you sure you don't want to use Location Services?"
    expect "Are you sure you don't want to"
    exec ${qemuSendKeys} "\\\\\<tab><delay><spc>"

    # "Select Your Time Zone"
    expect "Select Your Time Zone"
    exec ${qemuSendKeys} "\\\\\<tab><delay>UTC<delay><kp_enter><delay><shift-tab><delay><spc>"

    # "Analytics"
    expect "Analytics"
    exec ${qemuSendKeys} "\\\\\<tab><delay><spc><delay><shift-tab><delay><spc>"

    # "Screen Time"
    expect "Screen Time"
    exec ${qemuSendKeys} "\\\\\<tab><delay><spc>"

    # "Choose Your Look"
    expect "Choose Your Look"
    exec ${qemuSendKeys} "\\\\\<shift-tab><delay><spc>"

    # "Quit Keyboard Setup Assistant"
    expect "Keyboard Setup Assistant"
    exec ${qemuSendKeys} "\\\\\<meta_l-q><delay>"
    exec ${qemuSendMouse} 1 1

    expect "Shut Down"
    exec ${qemuSendKeys} "\\\\\<up><delay><up><delay><up><delay><delay><kp_enter>"
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
    echo EXECUTING THIS FUCKER ${expectScript}
    ${expectScript} &
    wait $openCoreBootPID
    mv mac_hdd_ng.img $out
  '';
in runInVm
