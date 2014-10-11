#!/usr/bin/python
# Check OS version, install bash update
# Lauren Caliolio 9/30/2014

import platform
import subprocess

OS = platform.mac_ver()[0]

if OS == "10.7.5":
    subprocess.call(['/usr/sbin/jamf', 'policy', '-trigger', 'LionBash'])
elif OS == "10.8.5":
    subprocess.call(['/usr/sbin/jamf', 'policy', '-trigger', 'MountainLionBash'])
elif OS == "10.9.5":
    subprocess.call(['/usr/sbin/jamf', 'policy', '-trigger', 'MavericksBash'])
else:
        print OS
        print "Unable to run update because OS is not 10.7.5, 10.8.5, or 10.9.5"
