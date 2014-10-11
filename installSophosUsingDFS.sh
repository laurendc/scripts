#!/bin/bash
# Install latest version of Sophos AV
# Modified version of installSophos20130607.sh
# Lauren Caliolio 9/5/2014

##### DEPENDENCY NOTES: ############################################################
##### This relies on: ##############################################################
##### 1) Sophos Enterprise Console #################################################
##### 2) a DFS namespace and referrals #############################################
##### It could be adapted to work in non-DFS environments through the use of rsync #
##### or whatever a Windows equivalent would be ####################################

# Some history notes on this script's history
# Original mount point and installer locations were in /tmp.
# New version of this script moves our two directories from /tmp/ to /usr/local/
# This was done as a form of error handling so we can still delete our directories that exist.
# Policies that error out because the directory still exists will still run the install this way.

SOPHOSMNT=/usr/local/sophos_mount
SOPHOSINSTALL=/usr/local/sophos_installer

# Verify if directories exist
if [ -d $SOPHOSMNT ];
then
    /bin/rm -r $SOPHOSMNT
    /bin/mkdir $SOPHOSMNT
else
    /bin/mkdir $SOPHOSMNT
fi

if [ -d $SOPHOSINSTALL ];
then
    /bin/rm -r $SOPHOSINSTALL
    /bin/mkdir $SOPHOSINSTALL
else
    /bin/mkdir $SOPHOSINSTALL
fi

# Perform DFS referral lookup
REFERRAL=`/usr/bin/smbutil dfs smb://your.company.com/DFS_namespace_with_Sophos_installer/ | /usr/bin/awk '/New Referral/ { print $7 }' | /usr/bin/cut -c 2- | /usr/bin/head -1`

# Copy installer to local mount point
/sbin/mount_smbfs -o nobrowse //'YourDomain;YourUsername:YourPassword'@${REFERRAL}/SophosUpdate/CIDs/S000/ESCOSX $SOPHOSMNT
/usr/bin/rsync -arv ${SOPHOSMNT}/ $SOPHOSINSTALL
/sbin/umount $SOPHOSMNT

# Install Sophos
/usr/sbin/installer -dumplog -verbose -pkg ${SOPHOSINSTALL}/Sophos\ Anti-Virus.mpkg -target /

# Clean up
/bin/rm -r $SOPHOSMNT
/bin/rm -r $SOPHOSINSTALL
