#!/bin/bash
#
# File:         mkit-wrapper.sh
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
 image="${1:-${DOCKER_IMAGE}}"; shift

 prefix="${1:-${PREFIX}}"; shift
 prefix="${prefix:-/app/httpd}" # sanity check

### MAIN ###

 [ "$isdocker" == "yes" ] &&
 {
  export DOCKER_BUILDKIT=1
  docker build -t "$image" --build-arg PROFILE=$PROFILE --build-arg PREFIX=$prefix .
  build_rc="$?"
  [ $build_rc -eq 0 -a ! -z "$image" ] && docker_hub "$image"
  exit $build_rc
 } ||
 { ./travis.sh "$prefix"; exit $?; }

### EOF ###
