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

# Bind Computer to AD - copy and paste bindtoAD-20121205.sh script
/usr/sbin/jamf recon

HOSTNAME=`scutil --get ComputerName | tr '[a-z]' '[A-Z]'`
USER='LDAP_Account'
PASS='LDAP_Password'
DOMAIN='your.company.com'
OU='OU=YourOU,OU=YourOU, DC=your,DC=company,DC=com'

/bin/echo "Hostname is set to $HOSTNAME"

/bin/echo "Binding computer to Active Directory"
/usr/sbin/dsconfigad -f -a "$HOSTNAME" -u "$USER" -p "$PASS" -ou "$OU" -domain "$DOMAIN"

/bin/echo "Creating mobile account at login"
/usr/sbin/dsconfigad -mobile enable
/bin/echo "Disabling confirmation for mobile account creation"
/usr/sbin/dsconfigad -mobileconfirm disable
/bin/echo "Forcing local home directory on startup disk"
/usr/sbin/dsconfigad -localhome enable
/bin/echo "Disabling UNC path use from AD"
/usr/sbin/dsconfigad -useuncpath disable
/bin/echo "Setting default user shell to bash"
/usr/sbin/dsconfigad -shell '/bin/bash'

/bin/echo "Setting no preferred domain server"
/usr/sbin/dsconfigad -nopreferred
/bin/echo "Setting domain admins, systems, and enterprise admins as groups allowed to administer computer"
/usr/sbin/dsconfigad -groups "domain admins,systems,enterprise admins"
/bin/echo "Disabling authentication from any domain in the forest"
/usr/sbin/dsconfigad -alldomains disable

/bin/echo "Setting authentication search locations"
/bin/echo "Adding ny.rga.com to search"
/usr/bin/dscl /Search -append / CSPSearchPath "/Active Directory/YourCompany/your.company.com"
/bin/echo "Removing All Domains from search"
/usr/bin/dscl /Search -delete / CSPSearchPath "/Active Directory/YourCompany/All Domains"

/bin/rm /var/log/secure.log
/usr/bin/touch /var/log/secure.log

/bin/echo "$HOSTNAME is now bound to Active Directory.  Running Recon again."
/usr/sbin/jamf recon

########## SYSTEM SETTINGS ##########

# Turn on SSH
/usr/sbin/systemsetup -setremotelogin on

# Add admin accounts to Sharing pane for ARD
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -privs -all -users AdminAccount

# Moving Mail App
# Remove this if you have no restrictions on the use of Apple Mail
/bin/mkdir /Applications/.Apple-Mail.noindex/
/bin/mv /Applications/Mail.app /Applications/.Apple-Mail.noindex/.Mail.app

# Disable Time Machine
/usr/bin/defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup 1

# Rename mini launcher to kill assistants at login
/bin/mv "/System/Library/CoreServices/Setup Assistant.app/Contents/SharedSupport/MiniLauncher" "/System/Library/CoreServices/Setup Assistant.app/Contents/SharedSupport/MiniLauncher.backup"

# Set SUS URL
/usr/bin/defaults write /var/root/Library/Preferences/com.apple.SoftwareUpdate CatalogURL http://yoursus.com:80/index.sucatalog
/usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate CatalogURL http://yoursus.com:80/index.sucatalog

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

# Show all filename extensions
/usr/bin/defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Set login window to name & password
/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true

# Removing System Preferences icon from Dock
# Requires the use of dockutil
/usr/local/bin/dockutil --remove 'System Preferences' '/System/Library/User Template/English.lproj/'
/usr/local/bin/dockutil --remove 'Mail' '/System/Library/User Template/English.lproj/'

# Disable iCloud popup
/usr/bin/defaults write "/System/Library/User Template/English.lproj/Library/Preferences/com.apple.SetupAssistant" DidSeeCloudSetup -bool TRUE
/usr/bin/defaults write "/System/Library/User Template/English.lproj/Library/Preferences/com.apple.SetupAssistant" DidSeeCloudSetup -int 1
/usr/bin/defaults write "/System/Library/User Template/English.lproj/Library/Preferences/com.apple.SetupAssistant" DidSeeCloudSetup -bool TRUE
/usr/bin/defaults write "/System/Library/User Template/English.lproj/Library/Preferences/com.apple.SetupAssistant" LastSeenCloudProductVersion 10.8.5

# Delete cruft
/bin/rm -R /Users/FolderThatShouldNotBeHere
/bin/rm -R /Users/FolderThatShouldNotBeHere
/bin/rm -R /Users/FolderThatShouldNotBeHere

# dockfixup.plist file adds Apple branded icons.  Deleting this.
/bin/rm -rf /Library/Preferences/com.apple.dockfixup.plist

# Install stuff via Casper policy
/usr/sbin/jamf policy -trigger postImagingML -verbose
/usr/sbin/jamf policy -trigger postImagingMav -verbose
/usr/sbin/jamf policy -trigger postImagingY -verbose
/usr/sbin/jamf policy -trigger installSophos -verbose

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
