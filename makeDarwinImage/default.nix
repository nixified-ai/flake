{ writeScript, writeShellScript, runCommand, vncdo, dmg2img, cdrkit, qemu_kvm, python311, tesseract, expect, socat, ruby, xorriso, callPackage, sshpass, openssh, lib, osx-kvm }:
{ diskSizeBytes ? 50000000000
, repeatabilityTest ? false
}:
let
  diskSize = if diskSizeBytes < 40000000000 then throw "diskSizeBytes ${toString diskSizeBytes} too small for macOS" else diskSizeBytes;

  installAssistant-fetched = import <nix/fetchurl.nix> {
    # Version 13.7.4 (22H420)
    url = "https://swcdn.apple.com/content/downloads/08/22/072-83845-A_XJNKWES8K3/95bsibbbgdt0eyfr278z60061tw15x7g40/InstallAssistant.pkg";
    sha256 = "sha256-iw7unRm3iKcwVbpJbQ740Fsg6rVAR88fDGXuB01zS9g=";
  };

  installAssistant-iso = runCommand "InstallAssistant.iso" { buildInputs = [ cdrkit ]; } ''
    cp --no-preserve=mode ${installAssistant-fetched} ./InstallAssistant.pkg
    mkisofs -allow-limited-size -l -J -r -iso-level 3 -V InstallAssistant -o $out ./InstallAssistant.pkg
  '';

  baseSystem-img = runCommand "BaseSystem.img" { nativeBuildInputs = [ python311 dmg2img qemu_kvm ];
    outputHashAlgo = "sha256";
    outputHash = "sha256-Qy9Whu8pqHo+m6wHnCIqURAR53LYQKc0r87g9eHgnS4=";
    outputHashMode = "recursive";
  } ''
    cp --no-preserve=mode ${osx-kvm}/fetch-macOS-v2.py .
    chmod +x ./fetch-macOS-v2.py
    patchShebangs ./fetch-macOS-v2.py
    ./fetch-macOS-v2.py --shortname ventura
    dmg2img -i BaseSystem.dmg $out
  '';

  tesseractScript = writeShellScript "tesseractScript" ''
    export OMP_THREAD_LIMIT=1
    cd $(mktemp -d)
    chmod -R 0755 $(pwd)
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
      cp cap.png cap-$(date +%Y-%m-%dT%H:%M:%S).png
    done
  '';

  # Utilities for running against the VM
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
  vncdoWrapper = writeScript "vncdoWrapper" ''
    echo Sending VNC inputs for $1
    sleep 10
    ${vncdo}/bin/vncdo --force-caps -s 127.0.0.1::5901 "''${@:2}"
  '';
  powerOffWrapper = writeScript "powerOffWrapper" ''
    while ! ${openssh}/bin/ssh-keyscan -p 2222 127.0.0.1
    do
      sleep 3
      echo SSH Not Ready
    done
    ${sshpass}/bin/sshpass -p admin ${openssh}/bin/ssh -o StrictHostKeyChecking=no -p 2222 admin@127.0.0.1 'set -e; killall -9 Terminal KeyboardSetupAssistant; while pgrep Terminal KeyboardSetupAssistant; do echo "Waiting for Terminal/KeyboardAssistant to die"; done; sleep 10; echo "admin" | sudo -S shutdown -h now'
    ssh_exit_code=$?
    if [ "$ssh_exit_code" == 255 ]; then
      echo "macOS terminated the SSH connection uncleanly on shutdown, ignoring..."
      echo "What a terrible operating system..."
      exit 0
    fi
  '';
  mouseJiggler = writeScript "mouseJiggler" ''
    while true
    do
      sleep $((RANDOM % (240 - 120 + 1) + 120))
      randomX=$((RANDOM % (1920 - 1910 + 1) + 1910))
      randomY=$((RANDOM % (1080 - 1070 + 1) + 1070))
      echo -e mouse_move $randomX $randomY | ${socat}/bin/socat - unix-connect:qemu-monitor-socket
    done
  '';


  # Expect scripts treat the first < as a special char, so need escapes like \\<
  expectScript = let
    sendUser = text: ''send_user "\n### NixThePlanet: ${text} ###\n"'';
  in writeScript "expect.sh" ''
    #!${expect}/bin/expect -f
    set debug 2
    set log_user 1
    set timeout -1
    exp_internal 0

    spawn ${tesseractScript}
    expect "Continue"
    exec ${qemuSendKeys} "\\<shift-meta_l-t>"
    expect "Terminal"
    expect "80x24"
    exec ${qemuSendKeys} "sh /Volumes/run_offline/run_offline.sh<kp_enter>"

    ${sendUser "Select Your Country or Region"}
    expect "Select Your Country or Region"
    exec ${qemuSendKeys} "united states<delay><shift-tab><delay><spc>"

    ${sendUser "Written and Spoken Languages"}
    expect "Written and Spoken Languages"
    exec ${qemuSendKeys} "\\<shift-tab><delay><spc>"

    ${sendUser "Accessibility"}
    expect "Accessibility"
    exec ${qemuSendKeys} "\\<shift-tab><delay><spc>"

    ${sendUser "How Do You Connect?"}
    expect "How Do You Connect?"
    exec ${qemuSendMouse} 815 480
    exec sleep 10
    exec ${qemuSendMouse} 1330 820

    ${sendUser "Your Mac isn't connected to the internet"}
    expect "Your Mac isn't connected to"
    exec ${qemuSendMouse} 1020 640

    ${sendUser "Data & Privacy"}
    expect "Data & Privacy"
    exec ${qemuSendKeys} "\\<shift-tab><delay><spc>"

    ${sendUser "Migration Assistant"}
    expect "Migration Assistant"
    exec ${qemuSendKeys} "\\<tab><delay><tab><delay><tab><delay><spc>"

    ## Not needed when offline
    # expect "Sign In with Your Apple ID"
    # exec ${vncdoWrapper} "Sign in with Your Apple ID" key shift-tab pause 10 key shift-tab pause 10 key space
    # expect "Are you sure you want to skip"
    # exec ${vncdoWrapper} "Are you sure you want to skip signing in with an Apple ID?" key tab pause 10 key space
    # expect "Terms and Conditions"

    ${sendUser "Terms and Conditions"}
    expect "Terms and Conditions"
    exec ${qemuSendKeys} "\\<shift-tab><delay><spc>"

    ${sendUser "I have read and agree to the macOS Software License Agreement."}
    expect "Software License"
    exec ${qemuSendKeys} "\\<tab><delay><spc>"

    ${sendUser "Create a Computer Account"}
    expect "Create a Computer Account"
    exec ${qemuSendKeys} "\\<delay>admin<delay><tab><delay>admin<delay><tab><delay>admin<delay><tab><delay>admin<delay><tab><delay><tab><delay><tab><delay><spc>"

    ${sendUser "Enable Location Services"}
    expect {
      "Enable Location Services" {}
      "account creation failed" {
        puts "###############################################################"
        puts "            ACCOUNT CREATION FAILED IN macOS VM"
        puts "            Perhaps the VM is too slow? Try again."
        puts "https://twitter.com/MatthewCroughan/status/1722665023338672230"
        puts "###############################################################"
        exit 1
      }
    }
    exec ${qemuSendKeys} "\\<shift-tab><delay><spc>"

    ${sendUser "Are you sure you don't want to use Location Services?"}
    expect "Are you sure you don't want to"
    exec ${qemuSendKeys} "\\<tab><delay><spc>"

    ${sendUser "Select Your Time Zone"}
    expect "Select Your Time Zone"
    exec ${qemuSendKeys} "\\<tab><delay>UTC<delay><kp_enter><delay><shift-tab><delay><spc>"

    ${sendUser "Analytics"}
    expect "Analytics"
    exec ${qemuSendKeys} "\\<tab><delay><spc><delay><shift-tab><delay><spc>"

    ${sendUser "Screen Time"}
    ${sendUser "Waiting for iCloud status check to appear"}
    expect -timeout 10 "iCloud Status"
    expect "Screen Time"
    ${sendUser "Waiting for iCloud status check to disappear"}
    expect -re "^(?!.*Checking iCloud status).*$"
    exec ${qemuSendKeys} "\\<tab><delay><spc>"

    ${sendUser "Choose Your Look"}
    expect "Choose Your Look"
    exec ${qemuSendKeys} "\\<shift-tab><delay><spc>"

    ${sendUser "Setting up SSH"}
    expect "Keyboard Setup Assistant"
    expect "Finder"
    exec ${qemuSendMouse} 400 1035
    expect "App Store"
    exec ${qemuSendKeys} "terminal"
    expect "Terminal"
    exec ${qemuSendKeys} "\\<kp_enter>"
    expect "80x24"
    exec ${qemuSendKeys} "sudo sh -ec 'launchctl load -w /System/Library/LaunchDaemons/ssh.plist; while ! ssh-keyscan 127.0.0.1; do echo SSH Not Ready; done'<kp_enter>"
    expect "Password"
    exec ${qemuSendKeys} "admin<kp_enter>"

    ${sendUser "OMG DID IT WORK???!!!!"}
    exit 0
  '';

  runInVm = runCommand "mac_hdd_ng.qcow2" {
    passthru = rec {
      makeRunScript = callPackage ./run.nix;
      runScript = makeRunScript {};
    };
    buildInputs = [ qemu_kvm xorriso ];
    # __impure = true; # set __impure = true; if debugging and want to connect via VNC during the build
  } ''
    set -x
    cp -r --no-preserve=mode ${osx-kvm} ./osx-kvm
    cp -r --no-preserve=mode ${./osx-kvm-additions}/* ./osx-kvm
    cd ./osx-kvm

    substituteInPlace scripts/run_offline.sh --replace '50000000000' "${toString diskSizeBytes}"

    mkdir x
    cp scripts/run_offline.sh x/run_offline.sh
    xorriso -volid run_offline -as mkisofs -o run_offline.iso x/
    qemu-img create -f qcow2 -b ${baseSystem-img} -F raw ./BaseSystem.qcow2
    qemu-img create -f qcow2 -b ${installAssistant-iso} -F raw ./InstallAssistant.qcow2
    qemu-img create -f qcow2 ./mac_hdd_ng.qcow2 ${toString diskSize} # 50 Gigabytes, not Gibibytes

    # Stage 1 installs macOS to the hard drive from the InstallAssistant
    sh ./OpenCore-Boot.sh &
    openCoreBootPID=$!
    ${expectScript} &
    expectPID=$!
    ${mouseJiggler} &
    wait $openCoreBootPID

    # Stage 2 continues the installation without the InstallAssistant drive
    # attached, necessary because OpenCore boot ordering is screwed up when
    # using Virtio
    sh ./OpenCore-Boot2.sh &
    openCoreBootPID=$!
    wait $expectPID
    ${powerOffWrapper}
    wait $openCoreBootPID

    ${lib.optionalString repeatabilityTest "echo makeDarwinImage succeeded > $out; exit 0"}
    mv mac_hdd_ng.qcow2 $out
  '';
in runInVm
