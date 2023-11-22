{ writeShellScriptBin
, makeDarwinImage
, qemu
, OVMF_CODE ? ./OSX-KVM/OVMF_CODE.fd
, OVMF_VARS ? ./OSX-KVM/OVMF_VARS-1920x1080.fd
, OpenCoreBoot ? ./OSX-KVM/OpenCore/OpenCore.qcow2
, threads ? 4
, cores ? 2
, sockets ? 1
, mem ? "4G"
, diskImage ? (makeDarwinImage {})
, extraQemuFlags ? []
, lib
}:
writeShellScriptBin "run-macOS.sh" ''
  MY_OPTIONS="+ssse3,+sse4.2,+popcnt,+avx,+aes,+xsave,+xsaveopt,check"

  args=(
    -enable-kvm -m "${mem}" -cpu Penryn,kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,"$MY_OPTIONS"
    -machine q35
    -usb -device usb-kbd -device usb-tablet -device usb-tablet
    -smp "${toString threads}",cores="${toString cores}",sockets="${toString sockets}"
    -device usb-ehci,id=ehci
    -device nec-usb-xhci,id=xhci
    -global nec-usb-xhci.msi=off
    -device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
    -drive if=pflash,format=raw,readonly=on,file="${OVMF_CODE}"
    -drive if=pflash,format=raw,readonly=on,file="${OVMF_VARS}"
    -smbios type=2
    -device ich9-intel-hda -device hda-duplex
    -drive id=OpenCoreBoot,if=virtio,snapshot=on,readonly=on,format=qcow2,file="${OpenCoreBoot}"
    -drive id=MacHDD,if=virtio,file="macos-ventura.qcow2",format=qcow2
    -netdev user,id=net0,hostfwd=tcp::2222-:22 -device virtio-net-pci,netdev=net0,id=net0,mac=52:54:00:c9:18:27
    -monitor stdio
    -device vmware-svga
#    -vnc 0.0.0.0:1
    ${lib.concatStringsSep " " extraQemuFlags}
  )

  if [ ! -f macos-ventura.qcow2 ]; then
    echo "macos-ventura.qcow2 not found, making disk image ./macos-ventura.qcow2"
    nix-store --realise ${diskImage} --add-root ./macos-ventura-base-image.qcow2
    ${qemu}/bin/qemu-img create -b ${diskImage} -F qcow2 -f qcow2 ./macos-ventura.qcow2
  fi

  ${qemu}/bin/qemu-system-x86_64 "''${args[@]}"
''
