#!/bin/bash
#
# requirements:
#   GNU wget  : download srcget & software
#   GNU tar   : j option (bzip2)
#

### FUNCTIONS ###

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
 ## "prefix" is the usual "GNU prefix" option i.e. the root of our install
 export prefix="${1:-$PWD}"

 # prefix: if a relative path make it absolute
 [ ${prefix} != ${prefix#./} ] &&
 {
  _prefix="${prefix#./}"
  prefix="${PWD}/${_prefix}"
 }

 export PATH="$prefix/bin:$PATH"
}

mkit_setup()
{
 export TIMESTAMP="$(date +%H%M_%d%m%y)"
 export WORKDIR="$PWD/mkit_workdir"
 export SRCGET="${WORKDIR}/srcget"
 export PATH="$PATH:$SRCGET"
 export RUNTIME_LIST=""
 export DOWNLOADS="${WORKDIR}/downloads"

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
 mkdir -p "$BUILDDIR"
 mkdir -p "$LOGSDIR"
 mkdir -p "$SRCDIR"
 mkdir -p "$DOWNLOADS"
}

### MAIN ###

 export MKIT=$(getdirfullpath $(dirname $0))

 . mkit.config.sh
 . mkit.profiles.sh

 export srcgetUrl="https://github.com/dellelce/srcget/archive"

 mkit_setup $*
 .  mkit.lib.sh
 .  mkit.components.sh

 echo "Install directory is ${prefix}"

 # download srcget
 get_srcget || { echo "Failed getting srcget, exiting..."; exit 1; }

 # launch default profile
 profile="${profile:-default}"
 profile_func="profile_${profile}"
 unset profile
 $profile_func

 exit $?

### EOF ###
