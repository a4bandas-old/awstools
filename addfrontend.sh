#!/bin/sh

LOG=/root/scripts/frontends.log

MTIME=$((`date +%s` - `stat -c %Y /root/scripts/last_added`))

if [ "$MTIME" -gt 250 ]; then
  echo "--> `date`" >> $LOG
  touch /root/scripts/last_added
  echo "Intenta agregar un FE" >> $LOG
  FOG_RC=/root/.fog /root/scripts/ec2-action.rb add-frontend >> $LOG 2>&1
#else
#  echo "addfrontend: Solo pasaron $MTIME seg." >> $LOG
fi

