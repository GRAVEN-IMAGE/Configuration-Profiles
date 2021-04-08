#!/bin/sh

#
# Set the portal address for GlobalProtect
#

portalAddress="vpn.globeandmail.ca"

#
# Modify PLIST to reflect the correct portal address.
#

echo '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>Palo Alto Networks</key><dict><key>GlobalProtect</key><dict><key>PanSetup</key><dict><key>Portal</key><string>'$portalAddress'</string><key>Prelogon</key><integer>0</integer></dict></dict></dict></dict></plist>' >> /Library/Preferences/com.paloaltonetworks.GlobalProtect.settings.plist