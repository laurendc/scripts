#!/bin/bash
# Change file creation date to previous date
# Assumes that the Xcode Command Line Tools are installed on the computer prior to running the script
# Lauren Caliolio 3/11/2014

########## CHANGELOG ##########
# 4/21/2014 added choose file and choose folder for AppleScript Runner
# 4/19/2014 replace cocoaDialog fileselect with osascript AppleScript Runner to address no selection
# 3/27/2014 quotes to accomodate string for FILESELECT
# 3/20/2014 sudo -u to FILESELECT
# 3/15/2014 username variable to run fileselect as currently logged in user

# Get currently logged in user
USERNAME=$(/usr/bin/who | /usr/bin/awk '/console/ { print $1 }')

# Set cocoaDialog location
CD="/Library/Application Support/JAMF/bin/cocoaDialog.app/Contents/MacOS/cocoaDialog"

# Set yesterday's & today's date
YESTERDAY=$(/bin/date -v-1d "+%m/%d/%Y")
TODAY=$(/bin/date)

# Prompt user to select file or folder that needs to be fixed
PROMPT=$("$CD" msgbox --icon finder --title "YourCompany Notification" \
    --text "Is this a file or a folder?" --informative-text "After you select your choice, please click on the greyed out file or folder" \
    --button1 "Folder" --button2 "File" --button3 "Cancel" --float)

# Condition for changing a file
if [[ $PROMPT == 1 ]];
then
    /bin/echo "User selected Folder"

    # Open Finder window to grab directory
    FOLDERSELECT=$(/usr/bin/sudo -u $USERNAME /usr/bin/osascript <<EOT
        tell app "AppleScript Runner"
        activate
        return posix path of (choose folder)
        end
        EOT)
    /bin/echo FOLDERSELECT is $FOLDERSELECT

    # Change creation date using xcode command line tools
    if [[ -n "$FOLDERSELECT" ]];
    then
        /usr/bin/SetFile -d $YESTERDAY "$FOLDERSELECT"
        /bin/echo "$FOLDERSELECT creation date changed to $YESTERDAY on $TODAY by $USERNAME"
        "$CD" ok-msgbox --icon folder --title "YourCompany Notification" --text "Your folder has been fixed. Please try again." \
            --no-cancel --float
        exit 0
    else
        /bin/echo "User did not select anything, closed window, or selected a file instead"
        exit 0
    fi
# Condition for changing a directory
elif [[ $PROMPT == 2 ]];
then
    /bin/echo "User selected File"

    # Open Finder window to select file
    FILESELECT=$(/usr/bin/sudo -u $USERNAME /usr/bin/osascript <<EOT
        tell app "AppleScript Runner"
        activate
        return posix path of (choose file)
        end
        EOT)

    # Change creation date with xcode command line tools
    if [[ -f "$FILESELECT" ]];
    then
        /usr/bin/SetFile -d $YESTERDAY "$FILESELECT"
        /bin/echo "$FILESELECT creation date changed to $YESTERDAY on $TODAY by $USERNAME"
        "$CD" ok-msgbox --icon notice --title "YourCompany Notification" --text "Your file has been fixed.  Please try again." \
            --no-cancel --float
        exit 0
    else
        /bin/echo "User did not select anything, closed window, or selected a folder instead"
        exit 0
    fi
# Cancel condition
elif [[ $PROMPT == 3 ]];
then
    /bin/echo "User canceled"
    exit 0
# End condition
else
    /bin/echo "User did not select any buttons and exited another way"
    exit 0
fi
