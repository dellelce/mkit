#!/bin/bash
#
# File:         travis-tmpfs.sh
# Created:      051219
# Description:  docker on tmpfs
#

## MAIN ##

 standby="/var/lib/docker-standby"
 mv /var/lib/docker "$standby"
 mkdir -p /var/lib/docker && mount -t tmpfs tmpfs /var/lib/docker; rc=$?
 [ $rc -ne 0 ] && exit $rc

 (
  cd $standby; tar cf - .
 ) |
 (
  cd /var/lib/docker; tar xf -
 )

 rm -rf "$standby"

## EOF ##
