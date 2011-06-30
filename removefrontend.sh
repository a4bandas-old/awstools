#!/bin/sh

LOG=/root/scripts/frontends.log

MTIME=$((`date +%s` - `stat -c %Y /root/scripts/last_removed`))

if [ "$MTIME" -gt 900 ]; then
  echo "--> `date`" >> $LOG
  touch /root/scripts/last_removed
  echo "Intenta sacar un FE" >> $LOG
  FOG_RC=/root/.fog /root/scripts/ec2-action.rb remove-frontend >> $LOG 2>&1
#else
#  echo "removefrontend: Solo pasaron $MTIME seg." >> $LOG
fi

