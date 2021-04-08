#!/bin/bash

theApp="/Applications/OneDrive.app"
launchAgent="/Library/LaunchAgents/com.MYCOMPANY.onedrive.plist"

## Set prefs User Template

/bin/mkdir -p /System/Library/User\ Template/English.lproj/Library/Containers/com.microsoft.OneDrive-mac/Data/Library/Preferences/
/usr/bin/touch /System/Library/User\ Template/English.lproj/Library/Containers/com.microsoft.OneDrive-mac/Data/Library/Preferences/com.microsoft.OneDrive-mac.plist
/usr/bin/defaults write /System/Library/User\ Template/English.lproj/Library/Containers/com.microsoft.OneDrive-mac/Data/Library/Preferences/com.microsoft.OneDrive-mac.plist DisablePersonalSync -bool TRUE
/usr/bin/defaults write /System/Library/User\ Template/English.lproj/Library/Containers/com.microsoft.OneDrive-mac/Data/Library/Preferences/com.microsoft.OneDrive-mac.plist Tenants '<dict><key>(TenantID)</key><dict><key>DefaultFolder</key><string>OneDrive - The Company Name</string></dict></dict>'
/bin/chmod -R 700 /System/Library/User\ Template/English.lproj/Library/Containers/com.microsoft.OneDrive-mac/Data/Library/Preferences/com.microsoft.OneDrive-mac.plist
/usr/sbin/chown root:wheel /System/Library/User\ Template/English.lproj/Library/Containers/com.microsoft.OneDrive-mac/Data/Library/Preferences/com.microsoft.OneDrive-mac.plist

## Set prefs Users

over500=$( dscl . list /Users UniqueID | awk '$2 > 500 { print $1 }' )

for u in $over500 ;
    do
        /bin/mkdir -p /Users/"$u"/Library/Containers/com.microsoft.OneDrive-mac/Data/Library/Preferences/
        /usr/bin/touch /Users/"$u"/Library/Containers/com.microsoft.OneDrive-mac/Data/Library/Preferences/com.microsoft.OneDrive-mac.plist
                /usr/bin/defaults write /Users/"$u"/Library/Containers/com.microsoft.OneDrive-mac/Data/Library/Preferences/com.microsoft.OneDrive-mac.plist DisablePersonalSync -bool TRUE
        /usr/bin/defaults write /Users/"$u"/Library/Containers/com.microsoft.OneDrive-mac/Data/Library/Preferences/com.microsoft.OneDrive-mac.plist Tenants '<dict><key>(TenantID)</key><dict><key>DefaultFolder</key><string>OneDrive - The Company Name</string></dict></dict>'
        /bin/chmod -R 700 /Users/"$u"/Library/Containers/com.microsoft.OneDrive-mac/Data/Library/Preferences/com.microsoft.OneDrive-mac.plist
        /usr/sbin/chown "$u" /Users/"$u"/Library/Containers/com.microsoft.OneDrive-mac/Data/Library/Preferences/com.microsoft.OneDrive-mac.plist
    done

## Create Launch Agent

/bin/echo '<?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>Disabled</key>
        <false/>
        <key>Label</key>
        <string>com.MYCOMPANY.onedrive</string>
        <key>ProgramArguments</key>
        <array>
            <string>/Applications/OneDrive.app/Contents/MacOS/OneDrive</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <dict>
            <key>SuccessfulExit</key>
            <false/>
        </dict>
    </dict>
    </plist>' > "$launchAgent"

/usr/bin/chown root:wheel "$launchAgent"
/bin/chmod 644 "$launchAgent"

## Load as current user

theUser=$( python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");' )

if [[ $theUser ]]; then

    theUID=$(id -u $theUser)
    /bin/launchctl bootstrap gui/"$theUID" "$launchAgent"

    ## For pre 10.10 computers
    if [[ $? -ne 0 ]]; then
        /bin/launchctl asuser "$theUID" open "$theApp"
    fi

fi

exit 0
