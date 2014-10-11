#!/bin/bash
# This extension attribute will let us know if the Mac has a specific SSID in its list of wireless networks.
# Type of the name of the SSID that you wish to find where it says TypeYourSSIDHere
# Lauren Caliolio 9/8/2014

WIFI_DEVICE=`/usr/sbin/networksetup -listallhardwareports | /usr/bin/egrep -A2 'Airport|Wi-Fi' | /usr/bin/awk '/Device/ { print $2 }'`
TypeYourSSIDHere=`/usr/sbin/networksetup -listpreferredwirelessnetworks $WIFI_DEVICE | /usr/bin/grep TypeYourSSIDHere | /usr/bin/sed 's|^[[:blank:]]*||g'`

if [[ $FORBIN = "TypeYourSSIDHere" ]];
then
    /bin/echo "<result>Yes</result>"
else
    /bin/echo "<result>No</result>"
fi
