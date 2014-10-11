#!/bin/sh
# Extension attribute to check if TRIM Support is enabled on a Solid State Drive
# Lauren Caliolio 7/14/2014

TRIM=$(/usr/sbin/system_profiler SPSerialATADataType | /usr/bin/awk '/TRIM Support/ { print $3 }')
/bin/echo "<result>$TRIM</result>"
