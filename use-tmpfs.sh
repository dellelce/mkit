#!/bin/bash
#
# File:         use-tmpfs.sh
# Created:      051219
# Description:  move docker main directory to tmpfs
#

## MAIN ##

 standby="/var/lib/docker-standby"
 libdocker="$(docker info -f '{{.DockerRootDir}}' )" # this is the default directory
 mv "$libdocker" "$standby"
 mkdir -p "$libdocker" && mount -t tmpfs tmpfs "$libdocker"; rc=$?
 [ $rc -ne 0 ] && exit $rc

 (
  cd "$standby"; tar cf - .
 ) |
 (
  cd "$libdocker"; tar xf -
 )

 rm -rf "$standby"

## EOF ##
