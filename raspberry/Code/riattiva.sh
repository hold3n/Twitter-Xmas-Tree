#!/bin/sh

if $(ps -A | grep python | grep -v grep > /dev/null ) ;
then
        exit ;
else
        sudo python /home/pi/scripts/paolo.py ;
fi
