#!/bin/sh

/usr/bin/xargs -a /root/scripts/backup.list -n 2 /usr/bin/s3cmd sync

