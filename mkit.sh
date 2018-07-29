#!/bin/bash
#
# requirements:
#   wget    : download srcget & software
#   GNU tar : j option (bzip2)
#

### ENV ###

 . mkit.config.sh
 . mkit.profiles.sh

 export srcgetUrl="https://github.com/dellelce/srcget/archive"

#
mkit_setup()
{
 export TIMESTAMP="$(date +%H%M_%d%m%y)"
 export WORKDIR="$PWD/mkit_workdir"
 export SRCGET="${WORKDIR}/srcget"
 export PATH="$PATH:$SRCGET"
 export BUILDLIST=""
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

 ## "prefix" is the usual "GNU prefix" option i.e. the root of our install
 export prefix="${1:-$PWD}"

 # prefix: if a relative path make it absolute
 [ ${prefix} != ${prefix#./} ] &&
 {
  _prefix="${prefix#./}"
  prefix="${PWD}/${_prefix}"
 }

 export PATH="$prefix/bin:$PATH"

 mkdir -p "$BUILDDIR"
 mkdir -p "$LOGSDIR"
 mkdir -p "$SRCDIR"
 mkdir -p "$DOWNLOADS"
}

### MAIN ###

 mkit_setup $*
 .  mkit.lib.sh
 .  mkit.components.sh

 echo "Install directory is ${prefix}"

 # download srcget
 get_srcget || { echo "Failed getting srcget, exiting..."; exit 1; }

 # TODO: check if perl is not installed at all?
 #       this does not clarify which component requires perl > 5.10
 eval $(getPerlVersions)

 [ "$PERL_REVISION" -eq 5 -a "$PERL_VERSION" -lt 10 ] &&
 {
  export BUILDLIST="perl ${BUILDLIST}"
  export PERL_NEEDED=1
  cat << EOF
   Detected version of perl is ${PERL_REVISION}.${PERL_VERSION}.${PERL_SUBVERSION} minimum required version is 5.10.
   Will download and build local version.

EOF
 }

 # launch default profile
 profile_default
 exit $?

### EOF ###
