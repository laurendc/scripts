#!/bin/bash
# Extension Attribute for finding Solid State Drives
# Taken and modified from https://jamfnation.jamfsoftware.com/discussion.html?id=4891
# Lauren Caliolio 5/1/2014

MEDIUM=$(/usr/sbin/system_profiler SPSerialATADataType | /usr/bin/awk '/Medium\ Type/ { print $3,$4 }')

/bin/echo "<result>$MEDIUM</result>"
