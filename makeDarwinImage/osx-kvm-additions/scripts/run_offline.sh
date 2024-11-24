#!/usr/bin/env bash

diskToErase=$(diskutil list -plist | plutil -convert json -o - - -r | grep -B2 50000000000 | awk -F '"' '{print $4}' | tr -d '\n')

diskutil eraseDisk APFS "macOS" "/dev/$diskToErase"
cd /Volumes/macOS
mkdir -p private/tmp
cp -R "/Install macOS Ventura.app" private/tmp
cd "private/tmp/Install macOS Ventura.app"
mkdir Contents/SharedSupport
cp -R /Volumes/InstallAssistant/InstallAssistant.pkg Contents/SharedSupport/SharedSupport.dmg
./Contents/Resources/startosinstall --agreetolicense --nointeraction --volume /Volumes/macOS
