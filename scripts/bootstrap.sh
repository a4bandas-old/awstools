#!/bin/sh

# Continua el boot con el script que se baja de S3 (tiene que ser public)
/root/scripts/runurl http://s3-eu-west-1.amazonaws.com/boot.otlive.es/boot-extra.sh $HOSTNAME

