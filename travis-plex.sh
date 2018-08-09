#!/bin/bash
#
# File:         travis-plex.sh
# Created:      270718
#

### FUNCTIONS ###

 docker_hub()
 {
  typeset target="$1"

  [ -z "$DOCKER_PASSWORD" -o -z "$DOCKER_USERNAME" ] && { echo "docker_hub: Docker environment not set-up correctly"; return 1; }
  echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
  rc=$?
  [ $rc -ne 0 ] && { echo "docker_hub: Docker hub login failed with rc = $rc"; return $rc; }

  [ ! -z "$target" ] && { docker push "$target"; return $?; }
  return 0
 }

### ENV ###

 isdocker="$1"; shift
 path="$1"; shift
 image="${1:-dellelce/mkit}"; shift

### MAIN ###

 set -x
 [ "$isdocker" == "yes" ] &&
 {
  docker build -t "$image" .
  build_rc="$?"
  [ $build_rc -eq 0 -a ! -z "$image" ] && docker_hub "$image"
  exit $build_rc
 } ||
 { ./travis.sh "$path"; exit $?; }

### EOF ###
