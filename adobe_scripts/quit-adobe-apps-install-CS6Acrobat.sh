#!/bin/bash
# Quit Adobe apps prior to installation of any Adobe application
# This is meant to be used with multiple installations of Adobe applications in Self Service
# Lauren Caliolio 6/4/2014

### Usage Notes ###
### With the JAMF Casper Suite, this script is meant to be used easily
### Simply change the name of the trigger listed under the installAdobeApp function
### to the name of the trigger that you wish to use
###################

# Set cocoaDialog location
CD="/Library/Application Support/JAMF/bin/cocoaDialog.app/Contents/MacOS/cocoaDialog"

# Change the trigger listed here to reflect the appropriate application
# Function for installing Adobe apps
installAdobeApp()
{
    /usr/sbin/jamf policy -trigger installCS6Acrobat
}

ADOBE=$(/bin/ps axc | /usr/bin/awk '/Adobe/ && !/AdobeCrashDaemon/ { print $5,$6,$7,$8 }')

# List & quit all open Adobe apps if they are open
if /usr/bin/pgrep Adobe > /dev/null
then
    # Prompt to quit all Adobe applications
    /bin/echo "Prompting user to quit all Adobe apps"
    QUIT=$( "$CD" msgbox --title "YourCompany Notification" \
        --text "Quit these applications before the software is installed:" \
        --informative-text "${ADOBE}" \
        --float --icon stop --button1 "Quit Applications Now" --button2 "Cancel")

    # Quit Adobe apps
    if [ "$QUIT" == "1" ]; then
        /bin/echo "User selected OK to quit apps"
        /bin/kill `/usr/bin/pgrep Adobe`

        # Install application
        /bin/echo "Running installation policy"
        installAdobeApp
        exit 0
    # User cancels installation and doesn't quit apps
    elif [ "$QUIT" == "2" ]; then
        /bin/echo "User canceled the installation"
        exit 0
    fi
else
    # Running installation since no Adobe apps are open
    /bin/echo "No Adobe applications are open"
    installAdobeApp
    exit 0
fi
