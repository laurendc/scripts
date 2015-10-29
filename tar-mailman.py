#!/usr/bin/python
# tarring all the mailman things

import tarfile
import datetime
import os

mailman = '/var/lib/mailman'
today = datetime.date.today()

tar = tarfile.open("/root/backups/mailman/mailmanbackup%s.tar.gz" % today, "w:gz")

for x in mailman:
    tar.add(x)

tar.close()
