#!/bin/bash
#
# mkit builds software from source (dowloaded by srcget).
#
# profile_NAME
#
# where "NAME" is the name of the package to pass as argument profile=NAME to mkit.sh.
#
# requirements:
#   GNU wget  : download srcget & software
#   GNU tar   : j option (bzip2)
#   srcget    : download packages
#

### FUNCTIONS ###

usage()
{
 cat << EOF
 mkit [profile=name of profile] install_directory

 Variables:
  - NO_TIMESTAMP: do not add timestamp in logfiles

EOF
}

getdirfullpath()
{
 export dp="$1";

 [ -z "$dp" ] && { unset dp; echo $PWD; return 0; }

 ( cd $dp; echo $PWD; )
 unset dp

 return $?
}

mkit_setup_prefix()
{
 typeset _prefix
 typeset default_prefix="$HOME/.install"

 ## "prefix" is the usual "GNU prefix" option i.e. the root of our install
 export prefix="${1:-$default_prefix}"

 # prefix: if a relative path make it absolute
 [ ${prefix} != ${prefix#./} ] &&
 {
  _prefix="${prefix#./}"
  prefix="${PWD}/${_prefix}"
 }

 export PATH="$prefix/bin:$PATH"
}

mkit_setup_paths()
{
 export TIMESTAMP="$(date +%H%M_%d%m%y)"
 export WORKDIR="$PWD/mkit_workdir"
 export SRCGET="${WORKDIR}/srcget"
 export PATH="$PATH:$SRCGET"
 export INSTALLED_LIST=""
 export BUILDTIME_LIST=""
 export RUNTIME_LIST=""
 export DOWNLOADS="${WORKDIR}/downloads"

 mkdir -p "$WORKDIR/state" # keep states of builds here

 [ -z "$TMP" ] && export TMP="/tmp"

 [ -z "$NO_TIMESTAMP" ] &&
 {
  export BUILDDIR="${WORKDIR}/build_${TIMESTAMP}"
  export SRCDIR="${WORKDIR}/src_${TIMESTAMP}"
 } ||
 {
  export BUILDDIR="${WORKDIR}/build"
  export SRCDIR="${WORKDIR}/src"
 }

 export LOGSDIR="${WORKDIR}/logs"

 mkdir -p "$BUILDDIR"
 mkdir -p "$LOGSDIR"
 mkdir -p "$SRCDIR"
 mkdir -p "$DOWNLOADS"
}

mkit_args()
{
 while [ "$1" != "" ]
 do
  arg="$1"

  # support two types of arguments: assignments & "prefix" (= install directory)
  [ "${arg/=/}" != "${arg}" ] &&
  {
    export $arg
  } ||
  {
    mkit_setup_prefix "$arg"
  }

  shift
 done

 [ -z "$prefix" ] && mkit_setup_prefix # make sure prefix is set with defaults if the previous block failed
}

### MAIN ###

 [ -z "$*" ] && { usage; exit; } # do not accept zero arguments

 export MKIT=$(getdirfullpath $(dirname $0))
 export srcgetUrl="https://github.com/dellelce/srcget/archive"

 . $MKIT/mkit.config.sh || exit $?
 . $MKIT/mkit.profiles.sh || exit $?

 mkit_setup_paths
 mkit_args $*

 . $MKIT/mkit.lib.sh || exit $?
 . $MKIT/mkit.build.sh || exit $?

 echo "Install directory is ${prefix}"

 # download srcget
 get_srcget || { echo "Failed getting srcget, exiting..."; exit 1; }

 # launch default profile if none is set already
 profile="${profile:-default}"
 profile_func="profile_${profile}"
 unset profile
 $profile_func
 run_build

 exit $?

### EOF ###
