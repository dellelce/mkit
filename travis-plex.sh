#!/bin/bash
#
# File:         travis-plex.sh
# Created:      270718
#

### ENV ###

 isdocker="$1"; shift
 path="$1"; shift

### MAIN ###

 set -x
 [ "$isdocker" == "yes" ] &&
 { docker build -t mkitbuild . ; exit $?; } ||
 { ./travis.sh "$path"; exit $?; }

### EOF ###
