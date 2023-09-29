#!/usr/bin/env bash

diskutil eraseDisk APFS "macOS" /dev/$(diskutil list | grep -B1 50.0 | grep -E "disk\\d+" --only)
cd /Volumes/macOS
mkdir -p private/tmp
cp -R "/Install macOS Ventura.app" private/tmp
cd "private/tmp/Install macOS Ventura.app"
mkdir Contents/SharedSupport
cp -R /Volumes/InstallAssistant/InstallAssistant.pkg Contents/SharedSupport/SharedSupport.dmg
./Contents/MacOS/InstallAssistant_springboard
