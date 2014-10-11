#!/usr/bin/python
# Clearing font caches
# Lauren Caliolio 7/8/2014

import subprocess

# Clearing the font cache
subprocess.call(['/usr/bin/atsutil', 'databases', '-remove'])

# Shutdown and restart ATSServer
subprocess.call(['/usr/bin/atsutil', 'server', '-shutdown'])
subprocess.call(['/usr/bin/atsutil', 'server', '-ping'])


