#!/bin/sh
# Unpause all paused print queues
# Lauren Caliolio 10/11/2014

# Check printer list for paused printers, unpause them
/usr/bin/lpstat -p | /usr/bin/awk '/disabled/ { print $2 }' | while read PRINTER
do
    /bin/echo "Clearing $PRINTER"
    /usr/sbin/cupsenable $PRINTER
done

# Notify user
/Library/Application\ Support/JAMF/bin/cocoaDialog.app/Contents/MacOS/cocoaDialog ok-msgbox --icon computer --no-cancel --title "Printer Cleared!" --text "Please try again." --informative-text "For further assistance, call the Help Desk to speak with a technician."
