#!/bin/bash
# Quit Lync to Upgrade Lync
# Meant to be used to push critical Lync update/s without interrupting the user's current Lync interaction
# Use with Casper Suite policy to nag user once a day to update Lync
# Lauren Caliolio 6/24/2014

# Set cocoaDialog location
CD="/Library/Application Support/JAMF/bin/cocoaDialog.app/Contents/MacOS/cocoaDialog"

# Function for silent push
SILENTinstallorupgradeApp()
{
    /usr/sbin/jamf policy -trigger installLync
}

# Function for push to user
NOISYinstallorupgradeApp()
{
    # Make pipe
    /bin/rm -f /tmp/hpipe
    /usr/bin/mkfifo /tmp/hpipe
    
    # Create background to pass installation through pipe
    "$CD" progressbar --indeterminate --title "Installing Microsoft Lync" --text "Please wait..." --icon "gear" --float < /tmp/hpipe &
    exec 3<> /tmp/hpipe
    
    # Putting progress bar on screen
    /bin/echo "Putting progress bar on the screen."
    /usr/sbin/jamf policy -trigger installLync -verbose 2>&1 | while read line; do
        /bin/echo "10 $line" >&3
    done
    
    # Wait for completion, clean up pipe
    /usr/bin/wait
    /bin/rm -f /tmp/hpipe
    
    # Tell user the installation is finished
    "$CD" ok-msgbox --title "YourCompany Notification" \
        --text "Microsoft Lync has been updated. You may use Lync now." \
        --informative-text "Please email helpdesk@YourCompany.com if there are any questions." --float --no-cancel --icon notice
}

# List & quit open apps if they are open
if /usr/bin/pgrep Lync > /dev/null
then
    # Prompt to quit relevant applications
    /bin/echo "Prompting user to quit relevant apps"
    QUIT=$( "$CD" msgbox  --title "YourCompany Notification" \
        --text "A critical update is available for Microsoft Lync." \
        --informative-text "Select Quit Now to close Lync and install the update." \
        --float --icon-file /Library/User\ Pictures/company_logo.jpg --button1 "Quit Now" --button2 "Cancel")

        # Quit apps
        if [ "$QUIT" == "1" ]; then
            /bin/echo "User selected OK to quit apps. Quitting apps."
            /bin/kill `/usr/bin/pgrep Lync`
            NOISYinstallorupgradeApp
            exit 0
        # User cancels installation and doesn't quit apps
        elif [ "$QUIT" == "2" ]; then
            /bin/echo "User canceled the installation"
            exit 0
        fi
else
    # Running installation since no relevant apps are open
    /bin/echo "No relevant apps open. Installing now."
    SILENTinstallorupgradeApp
    exit 0
fi
