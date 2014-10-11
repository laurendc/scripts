#!/bin/sh
# Adds Belkin driver adapter to Network interface list
# Lauren Caliolio 10/11/2014

# Get currently logged in user
USERNAME=$(/usr/bin/who | /usr/bin/awk '/console/ { print $1 }')

# Confirm driver
DRIVER=$(/usr/sbin/networksetup -listallhardwareports | /usr/bin/grep "Hardware Port: AX88179 USB 3.0 to Gigabit Ethernet")
if [[ "$DRIVER" == "AX88179 USB 3.0 to Gigabit Ethernet" ]];
then
    # Add adapter to Network interface list
    /usr/bin/sudo -u $USERNAME /usr/sbin/networksetup -detectnewhardware
    exit 0
else
    /bin/echo "Driver not installed or adapter is not plugged in"
fi
