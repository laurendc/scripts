#!/bin/bash
# Simple job to tar/cleanup top 20 biggest directories

DATE=$(date | awk '{ print $2,$3 }')
SRVCHK=$(df -h /mountpoint/filestotar/ | awk '!/Use/ { print $5 }' | cut -d'%' -f1)

# Tar list of top 20 biggest directories
TarFiles (){
    for x in $(du -hsx /path/to/fullfiles/* | sort -rh | head -20 | awk '{ print $2 }')
    do
        echo "tarring"
        tar -zcvf ${x}.tar.gz $x
    done
}

# Remove files just tarr'd
CleanUp (){
    for x in $(ls -la /path/to/fullfiles/*.tar.gz | grep "$DATE" | sed 's/.tar.gz/ /g')
    do
        echo "removing" 
        rm -r $x 
    done
}

# Tar & remove files if mount point is bigger than 80%, otherwise list all mntpoints
if [[ $SRVCHK -ge 80 ]] ;
then
    echo "Top 20 spacehogs in /path/to/fullfiles"
    echo "======================================="
    du -hsx /path/to/fullfiles/* | sort -rh | head -20
    echo ""
    TarFiles
    echo 
    CleanUp
else
    echo "/path/to/full/files/ is not full"
    df -h
    echo ""
fi
