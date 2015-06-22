#!/bin/sh

now="$(date +'%Y_%m_%d_%H')"
backupfilename="$now"_dump.rdb
backupfolder="/home/soso/redis-backups"
backupfullpath="$backupfolder/$backupfilename"
redisdbpath="/var/lib/redis/dump.rdb"
mkdir -p $backupfolder && sudo cp $redisdbpath $backupfullpath && sudo chown soso:soso $backupfullpath && gzip -f $backupfullpath
exit 0
