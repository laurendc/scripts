#!/bin/bash
# Run Adobe Updates using RUM for both CS6 and Creative Cloud
# Lauren Caliolio 5/10/2014

########## CHANGELOG ##########
# 5/20/2014 change condition to check for binary existence, remove use of which
###############################

# Set locations for RUM and RUM location check
CCRUM=$(/usr/sbin/RemoteUpdateManager)
CS6RUM=$(/Applications/.YourCompany/RemoteUpdateManager)

# Conditions for running RUM
if [ -x "$CCRUM" ] && [ -x "$CS6RUM" ];
then
    /bin/echo "Creative Cloud & CS6 RUM installed. Run CC RUM to update both."
    /usr/sbin/RemoteUpdateManager
    exit 0
elif [ -x "$CS6RUM" ] && [ ! -x "$CCRUM" ];
then
    /bin/echo "CS6 is installed.  Running CS6 RUM."
    /Applications/.YourCompany/RemoteUpdateManager
    exit 0
else
    /bin/echo "RUM is not installed or is in a different location"
    exit 0
fi
