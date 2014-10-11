#!/bin/bash
# Run a custom policy trigger via Self Service and provide a progress bar
# Requires the use of cocoaDialog
# Many thanks to the JAMFNation forum for the progressbar pieces which helped me learn this:
# https://jamfnation.jamfsoftware.com/discussion.html?id=7558
# Lauren Caliolio 4/4/2014

########## CHANGELOG ##########
# 4/17/2014 -verbose to everyHour process
# 4/5/2014 pgrep for $EVERYHOUR

# Set cocoaDialog location
CD="/Library/Application Support/JAMF/bin/cocoaDialog.app/Contents/MacOS/cocoaDialog"

# Make pipe
/bin/rm -f /tmp/hpipe
/usr/bin/mkfifo /tmp/hpipe
/bin/sleep 0.2

# Background job to take pipe input
"$CD" progressbar --indeterminate --title "Executing Policies" --text "Please wait..." --icon "gear" --float < /tmp/hpipe &

# Link file descriptor
exec 3<> /tmp/hpipe

# Run everyHour policies
EVERYHOUR=$(/usr/bin/pgrep -f "jamf policy -action everyHour -randomDelaySeconds 2700")
if [[ $EVERYHOUR -eq "0" ]];
then
    /bin/echo "everyHour not running.  Running everyHour now."
    /usr/sbin/jamf policy -trigger everyHour -verbose 2>&1 | while read line; do
        /bin/echo "10 $line" >&3
    done
else
    /bin/echo "Killing everyHour process"
    /bin/kill $EVERYHOUR
    /bin/echo "Running everyHour now"
    /usr/sbin/jamf policy -trigger everyHour -verbose 2>&1 | while read line; do
        /bin/echo "10 $line" >&3
    done
fi

# Let processes catch up
/usr/bin/wait

# Remove pipe
/bin/rm -f /tmp/hpipe

exit 0
