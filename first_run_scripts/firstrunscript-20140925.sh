#!/bin/bash

exec 1> /var/log/firstbootpackageinstall.log 2>&1

# Script to enforce settings in OSX image
# Meant to be used with First Boot Package Install.pkg
# Lauren Caliolio 7/22/2014

### Usage Notes ###
### This is a script that can be used for bootstrapping any Mac
### Works with 10.8 and 10.9 Macs with Casper Imaging and First Boot Package Install.pkg
### First Boot Package Install.pkg can be found here: http://derflounder.wordpress.com/2014/04/17/first-boot-package-install-revisited/
### Github link for First Boot Package Install: https://github.com/rtrouton/First-Boot-Package-Install

# Give some time for things to shift into place
/bin/sleep 30

# Detect new hardware
/usr/sbin/networksetup -detectnewhardware

# Set time based on current location
# Modified from script listed here: https://jamfnation.jamfsoftware.com/discussion.html?id=6835 by ericbenfer

# Setting initial time zone.  This gets changed after location services are enabled and option for setting time zone by location is enabled
/bin/sleep 10
TIMEZONE="America/New_York"
TIMESERVER="time.apple.com"

/bin/sleep 10
/usr/sbin/systemsetup -setusingnetworktime off

# Set initial time zone and time server
/bin/echo "Setting initial time zone and server, this will change based on the location of the device"
/usr/sbin/systemsetup -settimezone "$TIMEZONE"
/usr/sbin/systemsetup -setnetworktimeserver "$TIMESERVER"

# Enable location services
/bin/launchctl unload /System/Library/LaunchDaemons/com.apple.locationd.plist
UUID=`/usr/sbin/system_profiler SPHardwareDataType | grep "Hardware UUID" | cut -c22-57`
/usr/bin/defaults write /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd."$UUID" LocationServicesEnabled -int 1
/usr/sbin/chown -R _locationd:_locationd /var/db/locationd
/bin/launchctl load /System/Library/LaunchDaemons/com.apple.locationd.plist

# Set time zone automatically based on location
/usr/bin/defaults write /Library/Preferences/com.apple.timezone.auto Active -bool true

# Turn on network time, get current time zone and time
/usr/sbin/systemsetup -setusingnetworktime on
/usr/sbin/systemsetup -gettimezone
/usr/sbin/systemsetup -getnetworktimeserver



/bin/rm /var/log/secure.log
/usr/bin/touch /var/log/secure.log

/bin/echo "$HOSTNAME is now bound to Active Directory.  Running Recon again."
/usr/sbin/jamf recon

########## SYSTEM SETTINGS ##########

# Turn on SSH
/usr/sbin/systemsetup -setremotelogin on



# Disable Time Machine
/usr/bin/defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup 1

# Rename mini launcher to kill assistants at login
/bin/mv "/System/Library/CoreServices/Setup Assistant.app/Contents/SharedSupport/MiniLauncher" "/System/Library/CoreServices/Setup Assistant.app/Contents/SharedSupport/MiniLauncher.backup"


# Turn off bluetooth
/usr/bin/defaults write /Library/Preferences/com.apple.Bluetooth.plist ControllerPowerState 0

########## USER SETTINGS ######################################
########## Setting contents of Default User Template ##########

# Don't write DS Stores on network shares
/usr/bin/defaults write "/System/Library/User Template/English.lproj/Library/Preferences/com.apple.desktopservices" DSDontWriteNetworkStores true

# Set "Always Show Scroll Bars" for Global Preferences
/usr/bin/defaults write "/System/Library/User Template/English.lproj/Library/Preferences/".GlobalPreferences AppleShowScrollBars -string "Always"

# Show external mount points, hard drives, and servers on Desktop
/usr/bin/defaults write "/System/Library/User Template/English.lproj/Library/Preferences/com.apple.finder" ShowExternalHardDrivesOnDesktop -bool true
/usr/bin/defaults write "/System/Library/User Template/English.lproj/Library/Preferences/com.apple.finder" ShowHardDrivesOnDesktop -bool true
/usr/bin/defaults write "/System/Library/User Template/English.lproj/Library/Preferences/com.apple.finder" ShowMountedServersOnDesktop -bool true
/usr/bin/defaults write "/System/Library/User Template/English.lproj/Library/Preferences/com.apple.finder" ShowRemovableMediaOnDesktop -bool true


# Removing System Preferences icon from Dock
# Requires the use of dockutil
/usr/local/bin/dockutil --remove 'System Preferences' '/System/Library/User Template/English.lproj/'
/usr/local/bin/dockutil --remove 'Mail' '/System/Library/User Template/English.lproj/'

# Disable iCloud popup
/usr/bin/defaults write "/System/Library/User Template/English.lproj/Library/Preferences/com.apple.SetupAssistant" DidSeeCloudSetup -bool TRUE
/usr/bin/defaults write "/System/Library/User Template/English.lproj/Library/Preferences/com.apple.SetupAssistant" DidSeeCloudSetup -int 1
/usr/bin/defaults write "/System/Library/User Template/English.lproj/Library/Preferences/com.apple.SetupAssistant" DidSeeCloudSetup -bool TRUE
/usr/bin/defaults write "/System/Library/User Template/English.lproj/Library/Preferences/com.apple.SetupAssistant" LastSeenCloudProductVersion 10.8.5


# dockfixup.plist file adds Apple branded icons.  Deleting this.
/bin/rm -rf /Library/Preferences/com.apple.dockfixup.plist

# Install stuff via Casper policy
jamf policy -trigger OSXPostflightConfig
/usr/sbin/jamf policy -trigger OSXPostflightConfigL -verbose


# Re-index Spotlight
/usr/bin/mdutil -i off /
/bin/sleep 3
/bin/rm /.metadata_never_index
/bin/sleep 3
/bin/rm -R /.Spotlight-v100
/bin/sleep 3
/usr/bin/mdutil -i on /
/bin/sleep 3
/usr/bin/mdutil -E /
