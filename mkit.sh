#!/bin/bash
#
# requirements:
#   wget    : download srcget & software
#   GNU tar : j option (bzip2)
#

### ENV ###

# built-in defaults
SRCLIST="sqlite3 m4 autoconf suhosin bison apr aprutil httpd openssl php pcre libxml2"
export srcget="0.0.5.5"  #  srcget version
export srcgetUrl="https://github.com/dellelce/srcget/archive"

# "external" options
 . mkit.config.sh

# 
export TIMESTAMP="$(date +%H%M_%d%m%y)"
export WORKDIR="$PWD/mkit_workdir"
export SRCGET="$WORKDIR/srcget"
export PATH="$PATH:$SRCGET"
export BUILDDIR="$WORKDIR/build_${TIMESTAMP}"
export SRCDIR="$PWD/src_${TIMESTAMP}"
export LOGSDIR="${WORKDIR}/logs"

## "prefix" is the usual "GNU prefix" option i.e. the root of our install
export prefix="${1:-$PWD}"

# test prefix for relative directory

[ ${prefix} != ${prefix#./} ] &&
{
  _prefix="${prefix#./}"
  prefix="${PWD}/${_prefix}"
}

export PATH="$prefix/bin:$PATH"

mkdir -p "$BUILDDIR"
mkdir -p "$LOGSDIR"
mkdir -p "$SRCDIR"


### FUNCTIONS ###

 .  mkit.lib.sh

### MAIN ###

echo
echo "Install directory is ${prefix}"
echo

# download srcget
get_srcget || { echo "Failed getting srcget, exiting..."; exit 1; }

# download latest archives / builds name mapping
download || { echo "Download failed for one of the components"; exit 1; }

## Build steps

build_sqlite3 || exit $?

build_m4 || exit $?

build_autoconf || exit $?

build_bison || exit $?

build_pcre || exit $?

build_openssl || exit $?

build_apr || exit $?

build_aprutil || exit $?

build_libxml2 || exit $?

build_httpd || exit $?

build_php || exit $?

build_suhosin || exit $?

build_zlib || exit $?

build_python3 || exit $?

build_mod_wsgi || exit $?


### EOF ###
