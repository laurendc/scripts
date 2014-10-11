#!/bin/bash
# Extension attribute to find the wireless network that's first on the list
# Lauren Caliolio 8/22/2014



FIRST=`/usr/sbin/networksetup -listpreferredwirelessnetworks en1 | /usr/bin/awk 'NR==2{ print $1 }'`
/bin/echo "<result>$FIRST</result>"
